extends Minigame
## Haunted Maze (OPCIONAL): llega a la salida antes de que se apague la vela.
## A oscuras, con una vela que se consume y dos fantasmas persiguiendo.
## Las calabazas suman puntos; el tiempo sobrante da bonus. Dueño: Dev 2.
##
## El laberinto se construye desde [constant LAYOUT] con bloques de color.
## Cuando llegue el arte, reemplazar _build_maze() por un TileMapLayer
## (ver .agents/skills/integrar-assets).

const MAZE_GHOST_SCENE: PackedScene = preload("res://scenes/minigames/haunted_maze/maze_ghost.tscn")
const MAZE_PUMPKIN_SCENE: PackedScene = preload(
	"res://scenes/minigames/haunted_maze/maze_pumpkin.tscn"
)

const TILE: int = 48
const ORIGIN: Vector2 = Vector2(16, 80)
## '#' muro · '.' piso · 'S' inicio · 'E' salida. Fantasmas y calabazas
## aparecen en celdas de piso aleatorias, no se fijan aquí.
const LAYOUT: Array[String] = [
	"##########################",
	"#S...#.......#...........#",
	"#.##.#.#####.#.####.####.#",
	"#.#..#.#...#...#..#....#.#",
	"#.#.##.#.#.#####.##.##.#.#",
	"#.#....#.#.....#....#..#.#",
	"#.####.#.#####.#.####.##.#",
	"#....#...#...#.#.#.......#",
	"###.##########.#.#.#######",
	"#.......#....#...#......E#",
	"#.#####.#.##.#####.#.###.#",
	"#.....#...#........#...#.#",
	"##########################",
]
const WALL_LAYER: int = 8  # capa 4 "world"
## Radio de luz (px) por debajo del cual no se baja nunca, aunque diseño
## ponga un light_radius_end más chico: con menos no se ve el pasillo siguiente.
const MIN_LIGHT_RADIUS: float = 80.0
const GHOST_COUNT: int = 2

@export_group("Vela")
## Radio de luz (px) al empezar y al acabarse el tiempo.
@export var light_radius_start: float = 180.0
@export var light_radius_end: float = 110.0
@export var light_energy: float = 1.1
## Color de la oscuridad (multiplica todo el laberinto).
@export var darkness_color: Color = Palette.SHADOW

@export_group("Fantasmas")
## Velocidad (px/s) al empezar y al final. El jugador va a 260.
@export var ghost_speed_start: float = 120.0
@export var ghost_speed_end: float = 200.0
## Cada cuánto recalculan la ruta hacia el jugador.
@export var repath_interval_sec: float = 0.4
@export var points_lost_on_catch: int = 50
## Distancia mínima (en celdas de ruta, no en línea recta) al jugador al reaparecer.
@export var min_ghost_spawn_distance: int = 8
## Pausa tras reaparecer antes de volver a perseguir.
@export var ghost_respawn_delay_sec: float = 1.5

@export_group("Calabazas")
## Cuántas hay siempre en el mapa.
@export var pumpkin_count: int = 4
@export var points_per_pumpkin: int = 25
## Espera antes de que aparezca la que reemplaza a una recogida.
@export var pumpkin_respawn_delay_sec: float = 2.0
## Distancia mínima (celdas de ruta) al jugador donde puede aparecer una.
@export var min_pumpkin_spawn_distance: int = 4

@export_group("Puntaje")
@export var points_per_second_left: int = 10

var _start_position: Vector2 = Vector2.ZERO
var _start_cell: Vector2i = Vector2i.ZERO
var _exit_cell: Vector2i = Vector2i.ZERO
## Celdas de piso sin muro, inicio ni salida: de aquí sale toda la aleatoriedad.
var _floor_cells: Array[Vector2i] = []
var _ghosts: Array[MazeGhost] = []
var _pumpkins: Array[MazePumpkin] = []
var _astar: AStarGrid2D = AStarGrid2D.new()
var _rng: RandomNumberGenerator = RandomNumberGenerator.new()

@onready var _walls: StaticBody2D = %Walls
@onready var _pumpkins_root: Node2D = %Pumpkins
@onready var _player: MazePlayer = %Player
@onready var _exit: Area2D = %Exit
@onready var _darkness: CanvasModulate = %Darkness
@onready var _ghosts_root: Node2D = %Ghosts
@onready var _repath_timer: Timer = %RepathTimer
@onready var _ghost_release_timer: Timer = %GhostReleaseTimer


func _ready() -> void:
	_build_maze()
	_player.position = _start_position
	_darkness.color = darkness_color
	_update_candle()
	_exit.body_entered.connect(_on_exit_body_entered)
	_repath_timer.timeout.connect(_on_repath_timer_timeout)
	_ghost_release_timer.timeout.connect(_on_ghost_release_timer_timeout)
	for i: int in GHOST_COUNT:
		var ghost := MAZE_GHOST_SCENE.instantiate() as MazeGhost
		ghost.hide()
		ghost.caught_player.connect(_on_ghost_caught_player)
		_ghosts_root.add_child(ghost)
		_ghosts.append(ghost)


func _process(_delta: float) -> void:
	if not is_running:
		return
	_update_candle()


func _on_start() -> void:
	_rng.randomize()
	_player.position = _start_position
	_player.can_move = true
	_clear_pumpkins()
	for i: int in pumpkin_count:
		_spawn_pumpkin()
	_respawn_ghosts()
	_repath_timer.start(repath_interval_sec)


func _on_end() -> void:
	_player.can_move = false
	_repath_timer.stop()
	_ghost_release_timer.stop()
	for ghost: MazeGhost in _ghosts:
		ghost.can_move = false


func _on_exit_body_entered(body: Node2D) -> void:
	if body != _player or not is_running:
		return
	add_score(int(get_time_left()) * points_per_second_left)
	end_game()


func _on_ghost_caught_player() -> void:
	if not is_running:
		return
	add_score(-points_lost_on_catch)
	_player.position = _start_position
	_respawn_ghosts()


func _on_repath_timer_timeout() -> void:
	if not is_running:
		return
	var player_cell: Vector2i = _world_to_cell(_player.position)
	var speed: float = lerpf(ghost_speed_start, ghost_speed_end, get_progress())
	for ghost: MazeGhost in _ghosts:
		if not ghost.can_move:
			continue
		ghost.speed = speed
		var from: Vector2i = _world_to_cell(ghost.get_next_waypoint())
		var points: Array[Vector2] = []
		for cell: Vector2i in _astar.get_id_path(from, player_cell):
			points.append(_cell_center(cell))
		ghost.follow_path(points)


func _on_ghost_release_timer_timeout() -> void:
	if not is_running:
		return
	for ghost: MazeGhost in _ghosts:
		ghost.can_move = true
	_on_repath_timer_timeout()


func _build_maze() -> void:
	_astar.region = Rect2i(0, 0, LAYOUT[0].length(), LAYOUT.size())
	_astar.cell_size = Vector2(TILE, TILE)
	_astar.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	_astar.update()
	for y: int in LAYOUT.size():
		var row: String = LAYOUT[y]
		for x: int in row.length():
			var cell := Vector2i(x, y)
			match row[x]:
				"#":
					_add_wall(cell)
					_astar.set_point_solid(cell)
				"S":
					_start_cell = cell
					_start_position = _cell_center(cell)
				"E":
					_exit_cell = cell
					_exit.position = _cell_center(cell)
				_:
					_floor_cells.append(cell)
	# LAYOUT tiene bolsillos cerrados (p. ej. x 10-12, y 7): ahí nada debe aparecer.
	_floor_cells = _floor_cells.filter(
		func(cell: Vector2i) -> bool: return _path_distance(_start_cell, cell) >= 0
	)


func _add_wall(cell: Vector2i) -> void:
	var shape := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = Vector2(TILE, TILE)
	shape.shape = rect
	shape.position = _cell_center(cell)
	_walls.add_child(shape)
	var visual := ColorRect.new()
	visual.color = Palette.PURPLE
	visual.size = Vector2(TILE, TILE)
	visual.position = ORIGIN + Vector2(cell * TILE)
	visual.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_walls.add_child(visual)


func _clear_pumpkins() -> void:
	for pumpkin: MazePumpkin in _pumpkins:
		pumpkin.queue_free()
	_pumpkins.clear()


## Pone una calabaza en una celda libre aleatoria, sin otra calabaza y lejos
## del jugador. Las llamadas tardías (de un temporizador) no pasan del máximo.
func _spawn_pumpkin() -> void:
	if not is_running or _pumpkins.size() >= pumpkin_count:
		return
	var occupied: Array[Vector2i] = []
	for pumpkin: MazePumpkin in _pumpkins:
		occupied.append(_world_to_cell(pumpkin.position))
	var cells: Array[Vector2i] = _pick_random_cells(
		1, _world_to_cell(_player.position), min_pumpkin_spawn_distance, occupied
	)
	if cells.is_empty():
		return
	var pumpkin := MAZE_PUMPKIN_SCENE.instantiate() as MazePumpkin
	pumpkin.position = _cell_center(cells[0])
	pumpkin.collected.connect(_on_pumpkin_collected.bind(pumpkin))
	_pumpkins_root.add_child(pumpkin)
	_pumpkins.append(pumpkin)


func _on_pumpkin_collected(pumpkin: MazePumpkin) -> void:
	if not is_running:
		return
	add_score(points_per_pumpkin)
	_pumpkins.erase(pumpkin)
	pumpkin.queue_free()
	get_tree().create_timer(pumpkin_respawn_delay_sec, false).timeout.connect(_spawn_pumpkin)


## Pone los fantasmas en celdas aleatorias lejos del jugador y los congela
## [member ghost_respawn_delay_sec] para que pueda reaccionar.
func _respawn_ghosts() -> void:
	var player_cell: Vector2i = _world_to_cell(_player.position)
	var cells: Array[Vector2i] = _pick_random_cells(
		_ghosts.size(), player_cell, min_ghost_spawn_distance, []
	)
	for i: int in _ghosts.size():
		var ghost: MazeGhost = _ghosts[i]
		ghost.can_move = false
		ghost.teleport_to(_cell_center(cells[i]))
		ghost.show()
	_ghost_release_timer.start(ghost_respawn_delay_sec)


## Elige [param count] celdas distintas de [member _floor_cells], fuera de
## [param excluded] y a [param min_distance] celdas de ruta o más de [param origin].
## Si no alcanzan, relaja la distancia (y avisa) en vez de fallar.
func _pick_random_cells(
	count: int, origin: Vector2i, min_distance: int, excluded: Array[Vector2i]
) -> Array[Vector2i]:
	var candidates: Array[Vector2i] = []
	for cell: Vector2i in _floor_cells:
		if cell not in excluded and _path_distance(origin, cell) >= min_distance:
			candidates.append(cell)
	if candidates.size() < count and min_distance > 0:
		push_warning("[HauntedMaze] Pocas celdas a %d de distancia; se relaja." % min_distance)
		return _pick_random_cells(count, origin, floori(min_distance / 2.0), excluded)
	var picked: Array[Vector2i] = []
	while picked.size() < count and not candidates.is_empty():
		picked.append(candidates.pop_at(_rng.randi_range(0, candidates.size() - 1)))
	return picked


## Pasos de la ruta más corta entre dos celdas (sin diagonales); -1 si no hay ruta.
func _path_distance(from: Vector2i, to: Vector2i) -> int:
	return _astar.get_id_path(from, to).size() - 1


## La vela se consume con el tiempo: el radio va de start a end, nunca menos
## que [constant MIN_LIGHT_RADIUS].
func _update_candle() -> void:
	var radius: float = lerpf(light_radius_start, light_radius_end, get_progress())
	_player.set_candle(maxf(radius, MIN_LIGHT_RADIUS), light_energy)


func _cell_center(cell: Vector2i) -> Vector2:
	return ORIGIN + Vector2(cell * TILE) + Vector2(TILE, TILE) / 2.0


func _world_to_cell(point: Vector2) -> Vector2i:
	return Vector2i(((point - ORIGIN) / TILE).floor())
