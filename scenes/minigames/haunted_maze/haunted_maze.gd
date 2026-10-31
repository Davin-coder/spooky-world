extends Minigame
## Haunted Maze (OPCIONAL): llega a la salida antes de que se apague la vela.
## Los dulces suman puntos; el tiempo sobrante da bonus. Dueño: Dev 2.
##
## El laberinto se construye desde [constant LAYOUT] con bloques de color.
## Cuando llegue el arte, reemplazar _build_maze() por un TileMapLayer
## (ver .agents/skills/integrar-assets).

const TILE: int = 48
const ORIGIN: Vector2 = Vector2(16, 80)
## '#' muro · '.' piso · 'S' inicio · 'E' salida · 'C' dulce
const LAYOUT: Array[String] = [
	"##########################",
	"#S...#.......#......C....#",
	"#.##.#.#####.#.####.####.#",
	"#.#..#.#...#...#..#....#.#",
	"#.#.##.#.#.#####.##.##.#.#",
	"#.#....#.#.....#....#..#.#",
	"#.####.#.#####.#.####.##.#",
	"#...C#...#...#.#.#.......#",
	"###.##########.#.#.#######",
	"#.......#....#...#......E#",
	"#.#####.#.##.#####.#.###.#",
	"#C....#...#........#...#.#",
	"##########################",
]
const WALL_LAYER: int = 8  # capa 4 "world"
const PLAYER_LAYER: int = 1  # capa 1 "player"

@export var points_per_candy: int = 25
@export var points_per_second_left: int = 10

var _start_position: Vector2 = Vector2.ZERO
var _candy_cells: Array[Vector2i] = []

@onready var _walls: StaticBody2D = %Walls
@onready var _items: Node2D = %Items
@onready var _player: MazePlayer = %Player
@onready var _exit: Area2D = %Exit


func _ready() -> void:
	_build_maze()
	_player.position = _start_position
	_exit.body_entered.connect(_on_exit_body_entered)


func _on_start() -> void:
	_player.position = _start_position
	_player.can_move = true
	_spawn_candies()


func _on_end() -> void:
	_player.can_move = false


func _on_exit_body_entered(body: Node2D) -> void:
	if body != _player or not is_running:
		return
	add_score(int(get_time_left()) * points_per_second_left)
	end_game()


func _build_maze() -> void:
	for y: int in LAYOUT.size():
		var row: String = LAYOUT[y]
		for x: int in row.length():
			var cell := Vector2i(x, y)
			match row[x]:
				"#":
					_add_wall(cell)
				"S":
					_start_position = _cell_center(cell)
				"E":
					_exit.position = _cell_center(cell)
				"C":
					_candy_cells.append(cell)


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


func _spawn_candies() -> void:
	for child: Node in _items.get_children():
		child.queue_free()
	for cell: Vector2i in _candy_cells:
		var candy := Area2D.new()
		candy.collision_layer = 0
		candy.collision_mask = PLAYER_LAYER
		candy.position = _cell_center(cell)
		var shape := CollisionShape2D.new()
		var circle := CircleShape2D.new()
		circle.radius = 12.0
		shape.shape = circle
		candy.add_child(shape)
		var visual := ColorRect.new()
		visual.color = Palette.SLIME
		visual.size = Vector2(20, 20)
		visual.position = Vector2(-10, -10)
		visual.mouse_filter = Control.MOUSE_FILTER_IGNORE
		candy.add_child(visual)
		candy.body_entered.connect(_on_candy_body_entered.bind(candy))
		_items.add_child(candy)


func _on_candy_body_entered(body: Node2D, candy: Area2D) -> void:
	if body != _player or not is_running:
		return
	add_score(points_per_candy)
	candy.queue_free()


func _cell_center(cell: Vector2i) -> Vector2:
	return ORIGIN + Vector2(cell * TILE) + Vector2(TILE, TILE) / 2.0
