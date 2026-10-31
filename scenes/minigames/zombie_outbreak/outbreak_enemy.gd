class_name OutbreakEnemy
extends RefCounted
## Estado de un enemigo; independiente del renderer y de los autoloads.

var position: Vector2 = Vector2.ZERO
var kind: int = 0
var health: int = 1
var speed: float = 20.0
var radius: float = 5.0
var flash: float = 0.0
var phase: float = 0.0


func _init(at: Vector2 = Vector2.ZERO, variant: int = 0) -> void:
	position = at
	kind = variant
	health = [1, 1, 4][kind]
	speed = [18.0, 32.0, 13.0][kind]
	radius = 7.0 if kind == 2 else 5.0
