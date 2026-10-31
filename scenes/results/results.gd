extends Control
## Resultados de la última partida: puntaje, récord y opciones.

@onready var _name_label: Label = %NameLabel
@onready var _score_label: Label = %ScoreLabel
@onready var _best_label: Label = %BestLabel
@onready var _retry_button: Button = %RetryButton
@onready var _hub_button: Button = %HubButton


func _ready() -> void:
	var info: MinigameInfo = GameManager.current
	if info and not info.results_scene_path.is_empty() and _show_custom_results(info):
		return
	_name_label.text = info.display_name if info else "Partida"
	_score_label.text = str(GameManager.last_score)
	var best: int = GameManager.get_best(info.id) if info else GameManager.last_score
	_best_label.text = "¡Nuevo récord!" if GameManager.last_was_record else "Récord: %d" % best
	_retry_button.pressed.connect(GameManager.replay_current)
	_hub_button.pressed.connect(GameManager.go_to_hub)
	_retry_button.grab_focus()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("back"):
		GameManager.go_to_hub()


func _show_custom_results(info: MinigameInfo) -> bool:
	var packed: PackedScene = load(info.results_scene_path) as PackedScene
	if packed == null:
		return false
	var instance: Node = packed.instantiate()
	var presentation := instance as MinigameResults
	if presentation == null:
		instance.free()
		return false
	for child: Node in get_children():
		if child is CanvasItem:
			(child as CanvasItem).hide()
	add_child(presentation)
	presentation.retry_requested.connect(GameManager.replay_current)
	presentation.hub_requested.connect(GameManager.go_to_hub)
	presentation.bind(
		GameManager.last_score, GameManager.get_best(info.id), GameManager.last_completed
	)
	return true
