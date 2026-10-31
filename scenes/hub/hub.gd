extends Control
## Hub: muestra un botón por cada minijuego habilitado (se generan solos a
## partir de GameManager.minigames) y el total de la sesión.

const CARD_SIZE: Vector2 = Vector2(340, 160)

@onready var _grid: GridContainer = %Grid
@onready var _total_label: Label = %TotalLabel
@onready var _back_button: Button = %BackButton
@onready var _empty_label: Label = %EmptyLabel


func _ready() -> void:
	_back_button.pressed.connect(GameManager.go_to_main_menu)
	_total_label.text = "Total de la sesión: %d" % GameManager.get_session_total()
	_build_cards()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("back"):
		GameManager.go_to_main_menu()


func _build_cards() -> void:
	for child: Node in _grid.get_children():
		child.queue_free()
	_empty_label.visible = GameManager.minigames.is_empty()
	var first: Button = null
	for info: MinigameInfo in GameManager.minigames:
		var card := _make_card(info)
		_grid.add_child(card)
		if first == null:
			first = card
	if first:
		first.grab_focus()


func _make_card(info: MinigameInfo) -> Button:
	var card := Button.new()
	card.custom_minimum_size = CARD_SIZE
	card.add_theme_font_size_override("font_size", 24)
	var best: int = GameManager.get_best(info.id)
	card.text = "%s\n\nRécord: %d" % [info.display_name, best]
	card.tooltip_text = info.description
	if info.icon:
		card.icon = info.icon
		card.expand_icon = true
	card.pressed.connect(GameManager.play.bind(info))
	return card
