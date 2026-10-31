extends Node
## Verifica el flujo completo sin entrada manual: menú, hub, partida,
## resultados y regreso al hub. No modifica archivos del proyecto.
## Uso: godot --headless --path . res://tools/flow_test.tscn

const MENU_SCENE: String = "res://scenes/main_menu/main_menu.tscn"
const HUB_SCENE: String = "res://scenes/hub/hub.tscn"
const HOST_SCENE: String = "res://scenes/minigame_host/minigame_host.tscn"
const RESULTS_SCENE: String = "res://scenes/results/results.tscn"


func _ready() -> void:
	# El runner permanece en root mientras SceneLoader reemplaza current_scene.
	get_tree().current_scene = null
	_run.call_deferred()


func _run() -> void:
	await get_tree().process_frame
	if not await _navigate_to_hub():
		get_tree().quit(1)
		return
	if not await _finish_a_minigame():
		get_tree().quit(1)
		return
	if not await _return_to_hub():
		get_tree().quit(1)
		return
	print("FLOW TEST OK")
	get_tree().quit(0)


func _navigate_to_hub() -> bool:
	if GameManager.minigames.is_empty():
		return _fail("No hay minijuegos habilitados")
	GameManager.go_to_main_menu()
	if await _wait_for_scene(MENU_SCENE) == null:
		return _fail("No abrió el menú")
	GameManager.go_to_hub()
	if await _wait_for_scene(HUB_SCENE) == null:
		return _fail("No abrió el hub")
	return true


func _finish_a_minigame() -> bool:
	GameManager.play(GameManager.minigames[0])
	var host: Node = await _wait_for_scene(HOST_SCENE)
	if host == null:
		return _fail("No abrió el host")
	var minigame: Minigame = null
	for child: Node in host.get_children():
		if child is Minigame:
			minigame = child as Minigame
			break
	if minigame == null:
		return _fail("El host no instanció el minijuego")
	await get_tree().create_timer(3.0).timeout
	if not minigame.is_running:
		return _fail("El minijuego no arrancó después de la cuenta regresiva")
	minigame.end_game()
	if await _wait_for_scene(RESULTS_SCENE) == null:
		return _fail("No abrió resultados")
	return true


func _return_to_hub() -> bool:
	GameManager.go_to_hub()
	if await _wait_for_scene(HUB_SCENE) == null:
		return _fail("No regresó al hub")
	return true


func _wait_for_scene(path: String) -> Node:
	var deadline: int = Time.get_ticks_msec() + 5000
	while Time.get_ticks_msec() < deadline:
		await get_tree().process_frame
		var scene: Node = get_tree().current_scene
		if scene != null and scene.scene_file_path == path:
			return scene
	return null


func _fail(message: String) -> bool:
	printerr("FLOW TEST FAIL: ", message)
	return false
