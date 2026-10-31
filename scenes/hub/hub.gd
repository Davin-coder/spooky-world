extends Control
## Hub: muestra un botón por cada minijuego habilitado (se generan solos a
## partir de GameManager.minigames) y el total de la sesión.

const CARD_SIZE: Vector2 = Vector2(340, 160)

@onready var _grid: GridContainer = %Grid
@onready var _total_label: Label = %TotalLabel
@onready var _back_button: Button = %BackButton
@onready var _empty_label: Label = %EmptyLabel
@onready var _illustrated_button: Button = %IllustratedButton
@onready var _pixel_button: Button = %PixelButton
@onready var _collection_hint: Label = %CollectionHint
@onready var _background: ColorRect = %Background
@onready var _title: Label = %Title


func _ready() -> void:
	_back_button.pressed.connect(GameManager.go_to_main_menu)
	_total_label.text = "Total de la sesión: %d" % GameManager.get_session_total()
	_illustrated_button.pressed.connect(_set_collection.bind("illustrated"))
	_pixel_button.pressed.connect(_set_collection.bind("pixel_art"))
	_set_collection(GameManager.hub_collection)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("back"):
		GameManager.go_to_main_menu()


func _build_cards() -> void:
	for child: Node in _grid.get_children():
		_grid.remove_child(child)
		child.queue_free()
	var first: Button = null
	for info: MinigameInfo in GameManager.minigames:
		if info.collection != GameManager.hub_collection:
			continue
		var card := _make_card(info)
		_grid.add_child(card)
		if first == null:
			first = card
	if first:
		first.grab_focus()
	_empty_label.visible = first == null


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
	if info.collection == "pixel_art":
		card.custom_minimum_size = Vector2(1080, 300)
		card.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		card.add_theme_constant_override("icon_max_width", 400)
		card.text = (
			"ÚLTIMA GUARDIA\n\nPistola. Zombis. Un último amanecer.\n\n"
			+ "WASD + ratón  ·  60 segundos\n\nRécord: %d   ·   JUGAR" % best
		)
		var panel := StyleBoxFlat.new()
		panel.bg_color = Palette.PIXEL_GROUND
		panel.border_color = Palette.PIXEL_TEAL
		panel.set_border_width_all(2)
		panel.content_margin_left = 24
		panel.content_margin_right = 24
		card.add_theme_stylebox_override("normal", panel)
	return card


func _set_collection(collection: String) -> void:
	GameManager.hub_collection = collection
	var pixel: bool = collection == "pixel_art"
	_illustrated_button.button_pressed = not pixel
	_pixel_button.button_pressed = pixel
	_background.color = Palette.PIXEL_INK if pixel else Palette.DUSK
	_title.text = "Arcade de medianoche" if pixel else "Elige un minijuego"
	_collection_hint.text = (
		"Pixel art, pólvora y supervivencia. ¿Llegarás al amanecer?"
		if pixel
		else "Pequeños retos en una noche de Halloween."
	)
	_grid.columns = 1 if pixel else 3
	_build_cards()
