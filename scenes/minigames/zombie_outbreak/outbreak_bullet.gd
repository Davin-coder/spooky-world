class_name OutbreakBullet
extends RefCounted
## Proyectil con recorrido barrido entre el frame anterior y el actual.

var position: Vector2 = Vector2.ZERO
var previous: Vector2 = Vector2.ZERO
var velocity: Vector2 = Vector2.ZERO
var life: float = 0.9
