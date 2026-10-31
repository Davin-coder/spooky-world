class_name Pumpkin
extends Area2D
## Calabaza (o bomba) que cae. La canasta la detecta por colisión.

@export var fall_speed: float = 300.0
@export var is_bomb: bool = false

@export_group("Visual")
## Variantes de calabaza: cada aparición elige una al azar.
@export var pumpkin_textures: Array[Texture2D] = []
@export var bomb_texture: Texture2D
@export var pumpkin_scale: float = 0.85
@export var bomb_scale: float = 0.82
## Desplazamiento en píxeles de textura para centrar el cuerpo sobre la colisión
## (el tallo y la mecha quedan fuera del círculo).
@export var pumpkin_offset: Vector2 = Vector2(0.0, -12.0)
@export var bomb_offset: Vector2 = Vector2(-1.0, 7.0)
## Grados por segundo al caer; el sentido se elige al azar.
@export var spin_speed: float = 45.0

var _spin_rad: float = 0.0

@onready var _visual: Sprite2D = %Visual


func _ready() -> void:
	if is_bomb:
		_visual.texture = bomb_texture
		_visual.scale = Vector2.ONE * bomb_scale
		_visual.offset = bomb_offset
	else:
		_visual.texture = pumpkin_textures.pick_random()
		_visual.scale = Vector2.ONE * pumpkin_scale
		_visual.offset = pumpkin_offset
	_spin_rad = deg_to_rad(spin_speed) * (1.0 if randf() < 0.5 else -1.0)


func _physics_process(delta: float) -> void:
	position.y += fall_speed * delta
	_visual.rotation += _spin_rad * delta
	if position.y > get_viewport_rect().size.y + 64.0:
		queue_free()
