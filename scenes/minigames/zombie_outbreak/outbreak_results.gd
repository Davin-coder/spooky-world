extends MinigameResults
## Envia decisiones al padre; no usa GameManager ni cambia escenas.

@onready var _canvas: OutbreakResultsCanvas = %ResultCanvas


func bind(score_value: int, best: int, completed: bool) -> void:
	_canvas.score_value = score_value
	_canvas.best = best
	_canvas.completed = completed
	_canvas.queue_redraw()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("back"):
		hub_requested.emit()
	elif (
		event.is_action_pressed("ui_left")
		or event.is_action_pressed("ui_right")
		or event.is_action_pressed("ui_up")
		or event.is_action_pressed("ui_down")
	):
		_canvas.selection = 1 - _canvas.selection
	elif event.is_action_pressed("ui_focus_next"):
		_canvas.selection = 1 - _canvas.selection
	elif event.is_action_pressed("ui_accept"):
		_activate()
	elif event.is_action_pressed("zombie_fire"):
		var click := event as InputEventMouseButton
		var at: Vector2 = click.position * Vector2(320, 180) / size
		if OutbreakResultsCanvas.RETRY_RECT.has_point(at):
			_canvas.selection = 0
			_activate()
		elif OutbreakResultsCanvas.HUB_RECT.has_point(at):
			_canvas.selection = 1
			_activate()
	else:
		return
	_canvas.queue_redraw()
	get_viewport().set_input_as_handled()


func _activate() -> void:
	if _canvas.selection == 0:
		retry_requested.emit()
	else:
		hub_requested.emit()
