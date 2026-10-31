extends SceneTree
## Prueba de humo: carga cada minijuego, verifica el contrato y lo instancia.
##
## Uso (desde la raíz del proyecto, después de abrirlo una vez en el editor):
##   godot --headless --path . -s res://tools/smoke_test.gd
## Sale con código 0 si todo está bien, 1 si algo falla.

const MINIGAMES_DIR: String = "res://scenes/minigames"
const CORE_SCENES: Array[String] = [
	"res://scenes/main_menu/main_menu.tscn",
	"res://scenes/hub/hub.tscn",
	"res://scenes/results/results.tscn",
	"res://scenes/minigame_host/minigame_host.tscn",
]


func _initialize() -> void:
	var errors: PackedStringArray = []
	for path: String in CORE_SCENES:
		if not (load(path) is PackedScene):
			errors.append("No carga: %s" % path)
	for dir_name: String in DirAccess.get_directories_at(MINIGAMES_DIR):
		_check_minigame(MINIGAMES_DIR.path_join(dir_name), errors)
	if errors.is_empty():
		print("SMOKE TEST OK")
		quit(0)
	else:
		for e: String in errors:
			printerr("FALLA: ", e)
		quit(1)


func _check_minigame(dir: String, errors: PackedStringArray) -> void:
	var info_path: String = dir.path_join("minigame_info.tres")
	var info: MinigameInfo = load(info_path) as MinigameInfo
	if info == null:
		errors.append("%s no tiene minigame_info.tres válido" % dir)
		return
	if not dir.ends_with("_template") and String(info.id) != dir.get_file():
		errors.append("%s: id '%s' no coincide con la carpeta" % [info_path, info.id])
	var packed: PackedScene = load(info.scene_path) as PackedScene
	if packed == null:
		errors.append("%s: scene_path no carga (%s)" % [info_path, info.scene_path])
		return
	var node: Node = packed.instantiate()
	if not (node is Minigame):
		errors.append("%s: la raíz no extiende Minigame" % info.scene_path)
	else:
		print("OK  %s (%s)" % [info.display_name, info.scene_path])
	node.free()
