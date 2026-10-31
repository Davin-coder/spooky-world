class_name MazePlayer
extends CharacterBody2D
## Jugador del laberinto. Solo se mueve cuando [member can_move] es true.

@export var speed: float = 260.0

var can_move: bool = false


func _physics_process(_delta: float) -> void:
	if not can_move:
		velocity = Vector2.ZERO
		return
	velocity = Input.get_vector("move_left", "move_right", "move_up", "move_down") * speed
	move_and_slide()
