class_name Pumpkin
extends Area2D
## Calabaza (o bomba) que cae. La canasta la detecta por colisión.

@export var fall_speed: float = 300.0
@export var is_bomb: bool = false

@onready var _visual: ColorRect = %Visual


func _ready() -> void:
	# Placeholder: color según tipo. Al llegar el arte, cambiar por Sprite2D.
	_visual.color = Palette.BLOOD if is_bomb else Palette.PUMPKIN


func _physics_process(delta: float) -> void:
	position.y += fall_speed * delta
	if position.y > get_viewport_rect().size.y + 64.0:
		queue_free()
