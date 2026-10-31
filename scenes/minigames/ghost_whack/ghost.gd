class_name Ghost
extends Area2D
## Fantasma que aparece en una ventana. Clic = golpe. Si nadie lo toca en
## [member lifetime] segundos, se escapa.

signal whacked(ghost: Ghost)

## true = fantasma amigo: NO hay que tocarlo (resta puntos).
@export var is_friendly: bool = false
## Segundos visible antes de esconderse.
@export var lifetime: float = 1.2

var _done: bool = false

@onready var _visual: ColorRect = %Visual


func _ready() -> void:
	input_pickable = true
	input_event.connect(_on_input_event)
	# Placeholder: blanco = golpear, naranja = amigo. Cambiar por sprites.
	_visual.color = Palette.PUMPKIN if is_friendly else Palette.BONE
	scale = Vector2.ZERO
	create_tween().tween_property(self, "scale", Vector2.ONE, 0.12)
	get_tree().create_timer(lifetime).timeout.connect(_hide_away)


func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if _done:
		return
	var click := event as InputEventMouseButton
	if click and click.pressed and click.button_index == MOUSE_BUTTON_LEFT:
		_done = true
		whacked.emit(self)
		queue_free()


func _hide_away() -> void:
	if _done:
		return
	_done = true
	var tween: Tween = create_tween()
	tween.tween_property(self, "scale", Vector2.ZERO, 0.1)
	tween.tween_callback(queue_free)
