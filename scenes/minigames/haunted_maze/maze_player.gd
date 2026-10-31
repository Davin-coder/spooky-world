class_name MazePlayer
extends CharacterBody2D
## Jugador del laberinto. Solo se mueve cuando [member can_move] es true.
## Lleva la vela (%Candle); la raíz decide su tamaño con [method set_candle].

## Radio en píxeles de maze_light_texture.tres con texture_scale = 1 (256 px / 2).
const LIGHT_TEXTURE_RADIUS: float = 128.0

@export var speed: float = 260.0

var can_move: bool = false

@onready var _candle: PointLight2D = %Candle


func _physics_process(_delta: float) -> void:
	if not can_move:
		velocity = Vector2.ZERO
		return
	velocity = Input.get_vector("move_left", "move_right", "move_up", "move_down") * speed
	move_and_slide()


## Ajusta la luz de la vela: [param radius] en píxeles e intensidad [param energy].
func set_candle(radius: float, energy: float) -> void:
	_candle.texture_scale = radius / LIGHT_TEXTURE_RADIUS
	_candle.energy = energy
