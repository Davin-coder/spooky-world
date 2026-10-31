extends Minigame
## Pumpkin Catch: mueve la canasta y atrapa calabazas; evita las bombas.
## Dueño: Dev 2.

const PUMPKIN_SCENE: PackedScene = preload("res://scenes/minigames/pumpkin_catch/pumpkin.tscn")
const SIDE_MARGIN: float = 80.0

@export_group("Canasta")
@export var basket_speed: float = 650.0

@export_group("Dificultad")
@export var spawn_interval_start: float = 0.9
@export var spawn_interval_end: float = 0.35
@export var fall_speed_start: float = 260.0
@export var fall_speed_end: float = 560.0
@export_range(0.0, 1.0) var bomb_chance: float = 0.2

@export_group("Puntaje")
@export var points_per_pumpkin: int = 10
@export var bomb_penalty: int = 25

@onready var _basket: Area2D = %Basket
@onready var _pumpkins: Node2D = %Pumpkins
@onready var _spawn_timer: Timer = %SpawnTimer


func _ready() -> void:
	_basket.area_entered.connect(_on_basket_area_entered)
	_spawn_timer.timeout.connect(_spawn_pumpkin)


func _on_start() -> void:
	_clear_pumpkins()
	_basket.position.x = get_viewport_rect().size.x / 2.0
	_spawn_timer.start(spawn_interval_start)


func _on_end() -> void:
	_spawn_timer.stop()
	_clear_pumpkins()


func _physics_process(delta: float) -> void:
	if not is_running:
		return
	var direction: float = Input.get_axis("move_left", "move_right")
	var max_x: float = get_viewport_rect().size.x - SIDE_MARGIN
	var target_x: float = _basket.position.x + direction * basket_speed * delta
	_basket.position.x = clampf(target_x, SIDE_MARGIN, max_x)


func _spawn_pumpkin() -> void:
	var progress: float = get_progress()
	var pumpkin := PUMPKIN_SCENE.instantiate() as Pumpkin
	pumpkin.is_bomb = randf() < bomb_chance
	pumpkin.fall_speed = lerpf(fall_speed_start, fall_speed_end, progress)
	var max_x: float = get_viewport_rect().size.x - SIDE_MARGIN
	pumpkin.position = Vector2(randf_range(SIDE_MARGIN, max_x), -40.0)
	_pumpkins.add_child(pumpkin)
	_spawn_timer.wait_time = lerpf(spawn_interval_start, spawn_interval_end, progress)


func _on_basket_area_entered(area: Area2D) -> void:
	var pumpkin := area as Pumpkin
	if pumpkin == null or not is_running:
		return
	if pumpkin.is_bomb:
		add_score(-bomb_penalty)
	else:
		add_score(points_per_pumpkin)
	pumpkin.queue_free()


func _clear_pumpkins() -> void:
	for child: Node in _pumpkins.get_children():
		child.queue_free()
