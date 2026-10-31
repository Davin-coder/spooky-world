class_name MinigameHud
extends CanvasLayer
## HUD común a todos los minijuegos: puntaje, tiempo, cuenta regresiva e
## instrucciones. Lo crea y conecta MinigameHost; los minijuegos no lo tocan.

const COUNTDOWN_STEP_SEC: float = 0.6

var _minigame: Minigame

@onready var _score_label: Label = %ScoreLabel
@onready var _time_label: Label = %TimeLabel
@onready var _title_label: Label = %TitleLabel
@onready var _center_label: Label = %CenterLabel
@onready var _instructions_label: Label = %InstructionsLabel


func _process(_delta: float) -> void:
	if _minigame == null or not _minigame.is_running:
		return
	if _minigame.duration_sec > 0.0:
		_time_label.text = "%d s" % ceili(_minigame.get_time_left())


## Conecta el HUD a un minijuego y muestra sus datos.
func bind(minigame: Minigame, info: MinigameInfo) -> void:
	_minigame = minigame
	_minigame.score_changed.connect(_on_score_changed)
	_on_score_changed(0)
	_title_label.text = info.display_name if info else str(minigame.name)
	_instructions_label.text = info.instructions if info else ""
	_time_label.text = "%d s" % ceili(minigame.duration_sec) if minigame.duration_sec > 0.0 else ""


## Muestra 3, 2, 1, ¡YA! Usar con await.
func play_countdown() -> void:
	_center_label.show()
	_instructions_label.show()
	for n: int in [3, 2, 1]:
		_center_label.text = str(n)
		await get_tree().create_timer(COUNTDOWN_STEP_SEC).timeout
	_center_label.text = "¡YA!"
	await get_tree().create_timer(COUNTDOWN_STEP_SEC * 0.6).timeout
	_center_label.hide()
	_instructions_label.hide()


## Muestra el estado final: "¡Tiempo!" si se acabó el reloj, "¡Terminado!" si no.
func show_end(timed_out: bool) -> void:
	if timed_out:
		_time_label.text = "0 s"
	show_message("¡Tiempo!" if timed_out else "¡Terminado!")


## Muestra un mensaje grande en el centro.
func show_message(text: String) -> void:
	_center_label.text = text
	_center_label.show()


func _on_score_changed(new_score: int) -> void:
	_score_label.text = "Puntos: %d" % new_score
