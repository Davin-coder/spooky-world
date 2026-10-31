class_name MazePickup
extends Area2D
## Objeto recogible del laberinto (calabaza, reloj, vida). Avisa una sola vez
## con [signal collected] (su máscara es la capa del jugador). Si
## [member lifetime_sec] > 0, avisa con [signal expired] al acabarse ese tiempo.
## La raíz decide qué hace cada uno y lo borra.

signal collected
signal expired

## Segundos antes de desaparecer; 0 = se queda hasta que lo recojan.
## Se asigna antes de agregarlo al árbol.
var lifetime_sec: float = 0.0

var _done: bool = false


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	if lifetime_sec > 0.0:
		get_tree().create_timer(lifetime_sec, false).timeout.connect(_on_lifetime_timeout)


func _on_body_entered(_body: Node2D) -> void:
	if _done:
		return
	_done = true
	collected.emit()


func _on_lifetime_timeout() -> void:
	if _done:
		return
	_done = true
	expired.emit()
