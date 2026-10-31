extends CanvasLayer
## Autoload "SceneLoader": cambia de escena con un fundido a negro.
## Es el ÚNICO lugar donde se llama change_scene_to_file().

const FADE_SEC: float = 0.25

var _is_changing: bool = false
var _queued_path: String = ""
var _fade_rect: ColorRect


func _ready() -> void:
	layer = 100
	process_mode = Node.PROCESS_MODE_ALWAYS
	_fade_rect = ColorRect.new()
	_fade_rect.color = Palette.SHADOW
	_fade_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	_fade_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_fade_rect.modulate.a = 0.0
	add_child(_fade_rect)


## Cambia a la escena indicada con fundido. Si llega otro pedido mientras
## cambia, se encola (gana el último) y se ejecuta al terminar.
func change_scene(path: String) -> void:
	if _is_changing:
		_queued_path = path
		return
	_is_changing = true
	_fade_rect.mouse_filter = Control.MOUSE_FILTER_STOP
	await _fade_to(1.0)
	get_tree().paused = false
	var error: Error = get_tree().change_scene_to_file(path)
	if error != OK:
		push_error("[SceneLoader] No se pudo cargar %s (error %d)" % [path, error])
	await get_tree().process_frame
	await _fade_to(0.0)
	_fade_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_is_changing = false
	if not _queued_path.is_empty():
		var next_path: String = _queued_path
		_queued_path = ""
		change_scene(next_path)


func _fade_to(alpha: float) -> void:
	var tween: Tween = create_tween()
	tween.tween_property(_fade_rect, "modulate:a", alpha, FADE_SEC)
	await tween.finished
