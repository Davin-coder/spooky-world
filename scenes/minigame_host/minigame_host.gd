extends Node
## Host: instancia el minijuego elegido, le pone el HUD, hace la cuenta
## regresiva, lo arranca y reporta el puntaje a GameManager.
## Es el puente entre los minijuegos (que no saben nada del resto) y el juego.

const END_MESSAGE_SEC: float = 1.0

var _minigame: Minigame
var _leaving: bool = false

@onready var _hud: MinigameHud = %Hud


func _ready() -> void:
	var info: MinigameInfo = GameManager.current
	if info == null or info.scene_path.is_empty():
		push_error("[MinigameHost] No hay minijuego seleccionado.")
		GameManager.go_to_hub.call_deferred()
		return
	var packed: PackedScene = load(info.scene_path) as PackedScene
	var instance: Node = packed.instantiate() if packed else null
	_minigame = instance as Minigame
	if _minigame == null:
		push_error("[MinigameHost] %s no extiende Minigame." % info.scene_path)
		if instance:
			instance.free()
		GameManager.go_to_hub.call_deferred()
		return
	add_child(_minigame)
	move_child(_minigame, 0)
	_hud.bind(_minigame, info)
	_minigame.finished.connect(_on_minigame_finished)
	_minigame.exit_requested.connect(_on_exit_requested)
	if _minigame.use_shared_hud:
		await _hud.play_countdown()
	else:
		_hud.hide()
	if _leaving:
		return
	_minigame.start()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("back"):
		# Abandonar: vuelve al hub sin registrar puntaje.
		get_viewport().set_input_as_handled()
		_leaving = true
		GameManager.go_to_hub()


func _on_minigame_finished(final_score: int) -> void:
	if _leaving:
		return
	_hud.show_end(_minigame.timed_out, _minigame.out_of_lives)
	await get_tree().create_timer(END_MESSAGE_SEC).timeout
	if _leaving:
		return
	GameManager.report_result(final_score, _minigame.timed_out)


func _on_exit_requested() -> void:
	_leaving = true
	GameManager.go_to_hub()
