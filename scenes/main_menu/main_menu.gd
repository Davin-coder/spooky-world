extends Control
## Menú principal: título, Jugar y Salir.

@onready var _play_button: Button = %PlayButton
@onready var _quit_button: Button = %QuitButton


func _ready() -> void:
	_play_button.pressed.connect(GameManager.go_to_hub)
	_quit_button.pressed.connect(get_tree().quit)
	# En Web no se puede cerrar la pestaña desde el juego.
	_quit_button.visible = not OS.has_feature("web")
	_play_button.grab_focus()
