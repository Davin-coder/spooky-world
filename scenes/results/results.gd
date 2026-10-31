extends Control
## Resultados de la última partida: puntaje, récord y opciones.

@onready var _name_label: Label = %NameLabel
@onready var _score_label: Label = %ScoreLabel
@onready var _best_label: Label = %BestLabel
@onready var _retry_button: Button = %RetryButton
@onready var _hub_button: Button = %HubButton


func _ready() -> void:
	var info: MinigameInfo = GameManager.current
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
