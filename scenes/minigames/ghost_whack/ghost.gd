class_name Ghost
extends Area2D
## Fantasma que se asoma por una ventana desde dentro de la casa: la fachada,
## dibujada encima, tapa lo que queda bajo el alféizar. El origen del nodo es
## el centro del alféizar. Clic = golpe. Si nadie lo toca en
## [member lifetime] segundos, se esconde.

signal whacked(ghost: Ghost)

const RISE_SEC: float = 0.12
const HIDE_SEC: float = 0.1

## true = amigo (calabaza): NO hay que tocarlo (resta puntos).
@export var is_friendly: bool = false
## Segundos visible antes de esconderse.
@export var lifetime: float = 1.2

@export_group("Visual")
@export var ghost_texture: Texture2D
@export var friendly_texture: Texture2D
@export var ghost_scale: float = 0.81
@export var friendly_scale: float = 0.76
## Píxeles que sube sobre el alféizar al asomarse: es lo que queda visible.
@export var ghost_peek: float = 110.0
@export var friendly_peek: float = 82.0
## Píxeles bajo el alféizar al estar escondido, para que no asome por los
## bordes inclinados de las ventanas.
@export var hide_depth: float = 50.0
## Ancho de la zona de clic: más angosto que el sprite para no golpear a
## través del marco. El alto es lo que se asoma.
@export var hit_width: float = 72.0

var _done: bool = false

@onready var _visual: Sprite2D = %Visual
@onready var _shape: CollisionShape2D = %Shape


func _ready() -> void:
	input_pickable = true
	input_event.connect(_on_input_event)
	_visual.texture = friendly_texture if is_friendly else ghost_texture
	_visual.scale = Vector2.ONE * (friendly_scale if is_friendly else ghost_scale)
	# Origen arriba al centro: con position.y = -peek asoman justo peek píxeles.
	_visual.offset = Vector2(-_visual.texture.get_width() / 2.0, 0.0)
	var peek: float = friendly_peek if is_friendly else ghost_peek
	var hit_box := _shape.shape as RectangleShape2D
	hit_box.size = Vector2(hit_width, peek)
	_shape.position.y = -peek / 2.0
	_visual.position.y = hide_depth
	create_tween().tween_property(_visual, "position:y", -peek, RISE_SEC)
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
	tween.tween_property(_visual, "position:y", hide_depth, HIDE_SEC)
	tween.tween_callback(queue_free)
