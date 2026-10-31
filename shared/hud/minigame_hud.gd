class_name MinigameHud
extends CanvasLayer
## HUD común a todos los minijuegos: puntaje, tiempo, vidas, cuenta regresiva
## e instrucciones. Lo crea y conecta MinigameHost; los minijuegos no lo tocan.

const COUNTDOWN_STEP_SEC: float = 0.6
## Tamaño de cada ícono de vida (placeholder hasta que llegue el arte).
const LIFE_ICON_SIZE: Vector2 = Vector2(24.0, 28.0)
## Duración del destello al perder una vida.
const LIFE_FLASH_SEC: float = 0.35
## Escala inicial del ícono al perder una vida; vuelve a 1 con el destello.
const LIFE_FLASH_SCALE: float = 1.5
## Cuánto se ve el "+N s" al sumar tiempo (la mitad quieto, la mitad desvaneciéndose).
const TIME_BONUS_SHOW_SEC: float = 1.2

var _minigame: Minigame
var _life_icons: Array[ColorRect] = []
var _lives_shown: int = 0
var _time_bonus_tween: Tween

@onready var _score_label: Label = %ScoreLabel
@onready var _lives_box: HBoxContainer = %LivesBox
@onready var _time_label: Label = %TimeLabel
@onready var _time_bonus_label: Label = %TimeBonusLabel
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
	_minigame.lives_changed.connect(_on_lives_changed)
	_minigame.time_added.connect(_on_time_added)
	_on_score_changed(0)
	_build_life_icons(minigame.max_lives)
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


## Muestra el estado final: "¡Sin vidas!" si se acabaron las vidas, "¡Tiempo!"
## si se acabó el reloj y "¡Terminado!" en otro caso.
func show_end(timed_out: bool, out_of_lives: bool = false) -> void:
	if timed_out:
		_time_label.text = "0 s"
	if out_of_lives:
		show_message("¡Sin vidas!")
	elif timed_out:
		show_message("¡Tiempo!")
	else:
		show_message("¡Terminado!")


## Muestra un mensaje grande en el centro.
func show_message(text: String) -> void:
	_center_label.text = text
	_center_label.show()


func _on_score_changed(new_score: int) -> void:
	_score_label.text = "Puntos: %d" % new_score


func _on_lives_changed(lives: int) -> void:
	var lost: bool = lives < _lives_shown
	_lives_shown = lives
	_refresh_life_icons()
	if lost and lives >= 0 and lives < _life_icons.size():
		_flash_life_icon(_life_icons[lives])


func _on_time_added(seconds: float) -> void:
	_time_label.text = "%d s" % ceili(_minigame.get_time_left())
	_time_bonus_label.text = "+%s s" % String.num(seconds, 1).trim_suffix(".0")
	if _time_bonus_tween:
		_time_bonus_tween.kill()
	_time_bonus_label.modulate.a = 1.0
	_time_bonus_label.show()
	_time_bonus_tween = create_tween()
	_time_bonus_tween.tween_interval(TIME_BONUS_SHOW_SEC * 0.5)
	_time_bonus_tween.tween_property(
		_time_bonus_label, "modulate:a", 0.0, TIME_BONUS_SHOW_SEC * 0.5
	)
	_time_bonus_tween.tween_callback(_time_bonus_label.hide)


## Crea un ícono por vida. Con 0 vidas la fila no se muestra.
func _build_life_icons(count: int) -> void:
	for icon: ColorRect in _life_icons:
		icon.queue_free()
	_life_icons.clear()
	_lives_box.visible = count > 0
	for i: int in count:
		var icon := ColorRect.new()
		icon.custom_minimum_size = LIFE_ICON_SIZE
		icon.pivot_offset = LIFE_ICON_SIZE * 0.5
		icon.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_lives_box.add_child(icon)
		_life_icons.append(icon)
	_lives_shown = count
	_refresh_life_icons()


## Encendidas las vidas que quedan, apagadas las perdidas.
func _refresh_life_icons() -> void:
	for i: int in _life_icons.size():
		_life_icons[i].color = Palette.PUMPKIN if i < _lives_shown else Palette.PURPLE


func _flash_life_icon(icon: ColorRect) -> void:
	icon.color = Palette.BLOOD
	icon.scale = Vector2.ONE * LIFE_FLASH_SCALE
	var tween: Tween = icon.create_tween()
	tween.tween_property(icon, "scale", Vector2.ONE, LIFE_FLASH_SEC).set_trans(Tween.TRANS_BACK)
	tween.parallel().tween_property(icon, "color", Palette.PURPLE, LIFE_FLASH_SEC)
	# Al terminar, recolorea según las vidas actuales por si se ganó una a mitad.
	tween.tween_callback(_refresh_life_icons)
