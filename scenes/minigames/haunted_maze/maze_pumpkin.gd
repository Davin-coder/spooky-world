class_name MazePumpkin
extends Area2D
## Calabaza recogible del laberinto. Avisa una sola vez con [signal collected]
## (su máscara es la capa del jugador); la raíz suma puntos y la reemplaza.

signal collected

var _collected: bool = false


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(_body: Node2D) -> void:
	if _collected:
		return
	_collected = true
	collected.emit()
