extends Minigame
## Haunted Maze (OPCIONAL): llega a la salida antes de que se apague la vela.
## A oscuras, con una vela que se consume y fantasmas que persiguen (cada vez
## más). Tienes 3 vidas. Calabazas dan puntos, relojes dan tiempo y, muy
## rara vez, aparece una vida extra. El tiempo sobrante da bonus. Dueño: Dev 2.
##
## El tiempo lo lleva este script ([member time_limit_sec]) y no la base
## (duration_sec = 0), porque los relojes necesitan sumar tiempo.
##
## El laberinto se construye desde [constant LAYOUT] con bloques de color.
## Cuando llegue el arte, reemplazar _build_maze() por un TileMapLayer
## (ver .agents/skills/integrar-assets).

const MAZE_GHOST_SCENE: PackedScene = preload("res://scenes/minigames/haunted_maze/maze_ghost.tscn")
const MAZE_PUMPKIN_SCENE: PackedScene = preload(
	"res://scenes/minigames/haunted_maze/maze_pumpkin.tscn"
)
const MAZE_CLOCK_SCENE: PackedScene = preload("res://scenes/minigames/haunted_maze/maze_clock.tscn")
const MAZE_LIFE_SCENE: PackedScene = preload("res://scenes/minigames/haunted_maze/maze_life.tscn")

const TILE: int = 48
const ORIGIN: Vector2 = Vector2(16, 80)
## '#' muro · '.' piso · 'S' inicio · 'E' salida. Fantasmas y objetos
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

@export_group("Tiempo")
## Tiempo inicial. La dificultad llega al máximo al jugar este tiempo.
@export var time_limit_sec: float = 60.0
## Segundos que suma cada reloj.
@export var clock_bonus_sec: float = 8.0
## Espera hasta que aparece un reloj (al empezar y tras recoger uno).
## Solo hay uno a la vez.
@export var clock_spawn_interval_sec: float = 15.0

@export_group("Vela")
## Radio de luz (px) al empezar y con la dificultad al máximo.
@export var light_radius_start: float = 180.0
@export var light_radius_end: float = 110.0
@export var light_energy: float = 1.1
## Color de la oscuridad (multiplica todo el laberinto).
@export var darkness_color: Color = Palette.SHADOW

@export_group("Fantasmas")
## Fantasmas al empezar; se suma uno cada ghost_add_interval_sec hasta el máximo.
@export var ghost_count_start: int = 2
@export var ghost_count_max: int = 5
@export var ghost_add_interval_sec: float = 15.0
## Velocidad (px/s) al empezar y con la dificultad al máximo. El jugador va a 260.
@export var ghost_speed_start: float = 120.0
@export var ghost_speed_end: float = 200.0
## Cada cuánto recalculan la ruta hacia el jugador.
@export var repath_interval_sec: float = 0.4
@export var points_lost_on_catch: int = 50
## Distancia mínima (en celdas de ruta, no en línea recta) al jugador al aparecer.
@export var min_ghost_spawn_distance: int = 8
## Pausa tras aparecer antes de empezar a perseguir.
@export var ghost_respawn_delay_sec: float = 1.5

@export_group("Vidas")
@export var start_lives: int = 3
@export var max_lives: int = 5
## Cada life_spawn_check_sec hay life_spawn_chance de que aparezca una vida
## (solo si no hay otra y no tienes el máximo). Desaparece a los life_lifetime_sec.
@export var life_spawn_check_sec: float = 5.0
@export_range(0.0, 1.0) var life_spawn_chance: float = 0.01
@export var life_lifetime_sec: float = 10.0
## Cuánto se ve la pantalla de "¡Perdiste!" antes de terminar.
@export var game_over_screen_sec: float = 2.5

@export_group("Calabazas")
## Cuántas hay siempre en el mapa.
@export var pumpkin_count: int = 4
@export var points_per_pumpkin: int = 25
## Espera antes de que aparezca la que reemplaza a una recogida.
@export var pumpkin_respawn_delay_sec: float = 2.0
## Distancia mínima (celdas de ruta) al jugador donde aparece cualquier objeto
## (calabazas, relojes y vidas).
@export var min_pumpkin_spawn_distance: int = 4

@export_group("Puntaje")
@export var points_per_second_left: int = 10

var _start_position: Vector2 = Vector2.ZERO
var _start_cell: Vector2i = Vector2i.ZERO
var _exit_cell: Vector2i = Vector2i.ZERO
## Celdas de piso sin muro, inicio ni salida: de aquí sale toda la aleatoriedad.
var _floor_cells: Array[Vector2i] = []
var _ghosts: Array[MazeGhost] = []
var _pumpkins: Array[MazePickup] = []
var _clock: MazePickup = null
var _extra_life: MazePickup = null
var _lives: int = 0
var _time_left: float = 0.0
var _elapsed: float = 0.0
## true mientras se muestra "¡Perdiste!": todo quieto, esperando a end_game().
var _is_game_over: bool = false
var _astar: AStarGrid2D = AStarGrid2D.new()
var _rng: RandomNumberGenerator = RandomNumberGenerator.new()

@onready var _walls: StaticBody2D = %Walls
@onready var _pickups_root: Node2D = %Pickups
@onready var _player: MazePlayer = %Player
@onready var _exit: Area2D = %Exit
@onready var _darkness: CanvasModulate = %Darkness
@onready var _ghosts_root: Node2D = %Ghosts
@onready var _repath_timer: Timer = %RepathTimer
@onready var _clock_timer: Timer = %ClockTimer
@onready var _life_check_timer: Timer = %LifeCheckTimer
@onready var _game_over_timer: Timer = %GameOverTimer
@onready var _lives_label: Label = %LivesLabel
@onready var _time_label: Label = %TimeLabel
@onready var _game_over: Control = %GameOver
@onready var _game_over_subtitle: Label = %Subtitle


func _ready() -> void:
	_build_maze()
	_player.position = _start_position
	_darkness.color = darkness_color
	_time_left = time_limit_sec
	_lives = start_lives
	_update_candle()
	_update_ui()
	_exit.body_entered.connect(_on_exit_body_entered)
	_repath_timer.timeout.connect(_on_repath_timer_timeout)
	_clock_timer.timeout.connect(_on_clock_timer_timeout)
	_life_check_timer.timeout.connect(_on_life_check_timer_timeout)
	_game_over_timer.timeout.connect(end_game)


func _process(delta: float) -> void:
	if not _is_playing():
		return
	_elapsed += delta
	_time_left -= delta
	_update_candle()
	_update_ui()
	if ghost_add_interval_sec > 0.0:
		var extra: int = floori(_elapsed / ghost_add_interval_sec)
		if _ghosts.size() < mini(ghost_count_start + extra, ghost_count_max):
			_add_ghost()
	if _time_left <= 0.0:
		_time_left = 0.0
		timed_out = true
		end_game()


func _on_start() -> void:
	_rng.randomize()
	_is_game_over = false
	_game_over.hide()
	_elapsed = 0.0
	_time_left = time_limit_sec
	_lives = start_lives
	_player.position = _start_position
	_player.can_move = true
	_clear_pickups()
	for i: int in pumpkin_count:
		_spawn_pumpkin()
	_clear_ghosts()
	for i: int in ghost_count_start:
		_add_ghost()
	_repath_timer.start(repath_interval_sec)
	_clock_timer.start(clock_spawn_interval_sec)
	_life_check_timer.start(life_spawn_check_sec)
	_update_candle()
	_update_ui()


func _on_end() -> void:
	_freeze_world()
	_game_over_timer.stop()
	# El host muestra su propio mensaje final encima; no se tapan.
	_game_over.hide()


func _on_exit_body_entered(body: Node2D) -> void:
	if body != _player or not _is_playing():
		return
	add_score(int(_time_left) * points_per_second_left)
	end_game()


func _on_ghost_caught_player() -> void:
	if not _is_playing():
		return
	add_score(-points_lost_on_catch)
	_lives -= 1
	_update_ui()
	if _lives <= 0:
		_show_game_over()
		return
	_player.position = _start_position
	_respawn_ghosts()


func _on_ghost_woke_up(ghost: MazeGhost) -> void:
	if _is_playing():
		_repath_ghost(ghost)


func _on_repath_timer_timeout() -> void:
	if not _is_playing():
		return
	for ghost: MazeGhost in _ghosts:
		_repath_ghost(ghost)


func _on_pumpkin_collected(pumpkin: MazePickup) -> void:
	if not _is_playing():
		return
	add_score(points_per_pumpkin)
	_pumpkins.erase(pumpkin)
	pumpkin.queue_free()
	get_tree().create_timer(pumpkin_respawn_delay_sec, false).timeout.connect(_spawn_pumpkin)


func _on_clock_timer_timeout() -> void:
	if not _is_playing():
		return
	_clock = _spawn_pickup(MAZE_CLOCK_SCENE)
	if _clock == null:
		_clock_timer.start(clock_spawn_interval_sec)
		return
	_clock.collected.connect(_on_clock_collected)


func _on_clock_collected() -> void:
	if not _is_playing():
		return
	_time_left += clock_bonus_sec
	_clock.queue_free()
	_clock = null
	_clock_timer.start(clock_spawn_interval_sec)
	_update_ui()


func _on_life_check_timer_timeout() -> void:
	if not _is_playing() or _extra_life != null or _lives >= max_lives:
		return
	if _rng.randf() >= life_spawn_chance:
		return
	_extra_life = _spawn_pickup(MAZE_LIFE_SCENE, life_lifetime_sec)
	if _extra_life == null:
		return
	_extra_life.collected.connect(_on_extra_life_collected)
	_extra_life.expired.connect(_on_extra_life_expired)


func _on_extra_life_collected() -> void:
	if not _is_playing():
		return
	_lives = mini(_lives + 1, max_lives)
	_update_ui()
	_extra_life.queue_free()
	_extra_life = null


func _on_extra_life_expired() -> void:
	_extra_life.queue_free()
	_extra_life = null


## true si la partida está en juego (corriendo y sin la pantalla de "¡Perdiste!").
func _is_playing() -> bool:
	return is_running and not _is_game_over


## Sin vidas: congela todo, muestra "¡Perdiste!" y termina tras unos segundos.
func _show_game_over() -> void:
	_is_game_over = true
	_freeze_world()
	_game_over_subtitle.text = "Te quedaste sin vidas · Puntos: %d" % score
	_game_over.show()
	_game_over_timer.start(game_over_screen_sec)


func _freeze_world() -> void:
	_player.can_move = false
	_repath_timer.stop()
	_clock_timer.stop()
	_life_check_timer.stop()
	for ghost: MazeGhost in _ghosts:
		ghost.stop()


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


func _clear_pickups() -> void:
	for child: Node in _pickups_root.get_children():
		child.queue_free()
	_pumpkins.clear()
	_clock = null
	_extra_life = null


## Pone una calabaza. Las llamadas tardías (de un temporizador) no pasan del máximo.
func _spawn_pumpkin() -> void:
	if not _is_playing() or _pumpkins.size() >= pumpkin_count:
		return
	var pumpkin: MazePickup = _spawn_pickup(MAZE_PUMPKIN_SCENE)
	if pumpkin == null:
		return
	pumpkin.collected.connect(_on_pumpkin_collected.bind(pumpkin))
	_pumpkins.append(pumpkin)


## Instancia un objeto en una celda libre aleatoria, sin otro objeto y a
## [member min_pumpkin_spawn_distance] o más del jugador. null si no hay lugar.
func _spawn_pickup(scene: PackedScene, lifetime_sec: float = 0.0) -> MazePickup:
	var occupied: Array[Vector2i] = []
	for child: Node2D in _pickups_root.get_children():
		if not child.is_queued_for_deletion():
			occupied.append(_world_to_cell(child.position))
	var cells: Array[Vector2i] = _pick_random_cells(
		1, _world_to_cell(_player.position), min_pumpkin_spawn_distance, occupied
	)
	if cells.is_empty():
		return null
	var pickup := scene.instantiate() as MazePickup
	pickup.position = _cell_center(cells[0])
	pickup.lifetime_sec = lifetime_sec
	_pickups_root.add_child(pickup)
	return pickup


func _clear_ghosts() -> void:
	for ghost: MazeGhost in _ghosts:
		ghost.queue_free()
	_ghosts.clear()


## Agrega un fantasma lejos del jugador y de los demás; espera antes de perseguir.
func _add_ghost() -> void:
	var occupied: Array[Vector2i] = []
	for other: MazeGhost in _ghosts:
		occupied.append(_world_to_cell(other.position))
	var cells: Array[Vector2i] = _pick_random_cells(
		1, _world_to_cell(_player.position), min_ghost_spawn_distance, occupied
	)
	if cells.is_empty():
		return
	var ghost := MAZE_GHOST_SCENE.instantiate() as MazeGhost
	ghost.position = _cell_center(cells[0])
	ghost.caught_player.connect(_on_ghost_caught_player)
	ghost.woke_up.connect(_on_ghost_woke_up.bind(ghost))
	_ghosts_root.add_child(ghost)
	_ghosts.append(ghost)
	ghost.freeze_for(ghost_respawn_delay_sec)


## Pone todos los fantasmas en celdas aleatorias lejos del jugador y los
## congela [member ghost_respawn_delay_sec] para que pueda reaccionar.
func _respawn_ghosts() -> void:
	var cells: Array[Vector2i] = _pick_random_cells(
		_ghosts.size(), _world_to_cell(_player.position), min_ghost_spawn_distance, []
	)
	for i: int in mini(cells.size(), _ghosts.size()):
		_ghosts[i].teleport_to(_cell_center(cells[i]))
		_ghosts[i].freeze_for(ghost_respawn_delay_sec)


func _repath_ghost(ghost: MazeGhost) -> void:
	if not ghost.can_move:
		return
	ghost.speed = lerpf(ghost_speed_start, ghost_speed_end, _get_difficulty())
	var from: Vector2i = _world_to_cell(ghost.get_next_waypoint())
	var points: Array[Vector2] = []
	for cell: Vector2i in _astar.get_id_path(from, _world_to_cell(_player.position)):
		points.append(_cell_center(cell))
	ghost.follow_path(points)


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


## Dificultad de 0 a 1 según el tiempo jugado (no el que queda: los relojes
## suman tiempo pero no deben hacer el juego más fácil).
func _get_difficulty() -> float:
	if time_limit_sec <= 0.0:
		return 0.0
	return clampf(_elapsed / time_limit_sec, 0.0, 1.0)


## La vela se consume con el tiempo jugado: el radio va de start a end, nunca
## menos que [constant MIN_LIGHT_RADIUS].
func _update_candle() -> void:
	var radius: float = lerpf(light_radius_start, light_radius_end, _get_difficulty())
	_player.set_candle(maxf(radius, MIN_LIGHT_RADIUS), light_energy)


func _update_ui() -> void:
	_lives_label.text = "Vidas: %d" % _lives
	_time_label.text = "%d s" % ceili(_time_left)


func _cell_center(cell: Vector2i) -> Vector2:
	return ORIGIN + Vector2(cell * TILE) + Vector2(TILE, TILE) / 2.0


func _world_to_cell(point: Vector2) -> Vector2i:
	return Vector2i(((point - ORIGIN) / TILE).floor())
