extends Node
## Integra categoria, host, pausa, fin, resultados pixel y reintento.
## Con -- --capture guarda una captura real si hay renderer grafico.

const HOST: String = "res://scenes/minigame_host/minigame_host.tscn"
const RESULTS: String = "res://scenes/results/results.tscn"
const HUB: String = "res://scenes/hub/hub.tscn"

var _tree: SceneTree
var _errors: PackedStringArray = []


func _ready() -> void:
	_tree = get_tree()
	_tree.current_scene = null
	_run.call_deferred()


func _run() -> void:
	_tree.create_timer(20).timeout.connect(func() -> void: _tree.quit(1))
	var info: MinigameInfo = null
	for candidate: MinigameInfo in GameManager.minigames:
		if candidate.id == &"zombie_outbreak":
			info = candidate
	if info == null:
		_fail("No se descubre el minijuego")
		return
	if not await _test_session(info):
		return
	if not await _test_replay():
		return
	if _errors.is_empty():
		print("ZOMBIE FLOW TEST OK")
	else:
		for message: String in _errors:
			printerr(message)
	_tree.quit(0 if _errors.is_empty() else 1)


func _test_session(info: MinigameInfo) -> bool:
	GameManager.hub_collection = "pixel_art"
	GameManager.go_to_hub()
	if not await _wait_scene(HUB):
		return false
	var grid: GridContainer = _tree.current_scene.get_node("%Grid") as GridContainer
	_check(grid.get_child_count() == 1, "La categoria pixel contiene su juego")
	await _capture_image("zombie_hub")
	GameManager.play(info)
	if not await _wait_scene(HOST):
		return false
	var game: ZombieOutbreak = _find_game()
	if game == null:
		_fail("El host no instancia ZombieOutbreak")
		return false
	await _test_game(game)
	game.simulation.hurt_left = 0
	game.simulation.damage_player(200)
	if not await _wait_scene(RESULTS):
		return false
	_check(_tree.current_scene.has_node("OutbreakResults"), "Resultados propios de pixel art")
	_check(not GameManager.last_completed, "Derrota conserva el resultado correcto")
	await _capture_image("zombie_results")
	return true


func _test_replay() -> bool:
	GameManager.replay_current()
	if not await _wait_scene(HOST):
		return false
	var replay: ZombieOutbreak = _find_game()
	_check(replay != null and replay.score == 0, "Reintento crea partida nueva")
	var timer: Timer = replay.get("_timer") as Timer
	timer.start(0.1)
	if not await _wait_scene(RESULTS):
		return false
	_check(GameManager.last_completed, "Completar el reloj produce supervivencia")
	GameManager.go_to_hub()
	if not await _wait_scene(HUB):
		return false
	_check(GameManager.hub_collection == "pixel_art", "Conserva categoria al volver")
	return true


func _test_game(game: ZombieOutbreak) -> void:
	game.pause_game(true)
	var before: float = game.get_time_left()
	var elapsed_before: float = game.simulation.elapsed
	await _tree.create_timer(0.2).timeout
	_check(absf(game.get_time_left() - before) < 0.04, "Pausa congela reloj")
	_check(absf(game.simulation.elapsed - elapsed_before) < 0.001, "Pausa congela simulacion")
	game.pause_game(false)
	await _test_input(game)
	_check(game.simulation.elapsed > 0.1, "Reanudar permite avanzar")
	if "--capture" in OS.get_cmdline_user_args() and DisplayServer.get_name() != "headless":
		game.simulation.reset(2026)
		game.simulation.elapsed = 24
		game.simulation.wave = 2
		var timer: Timer = game.get("_timer") as Timer
		timer.start(36)
		game.score = 120
		game.simulation.kills = 6
		game.simulation.health = 80
		var mouse := InputEventMouseMotion.new()
		mouse.position = Vector2(220, 100) * game.get_viewport_rect().size / Vector2(320, 180)
		game.get_viewport().push_input(mouse, true)
		game.simulation.spawn_enemy(Vector2(215, 110), 2)
		game.simulation.spawn_enemy(Vector2(96, 87), 1)
		game.simulation.spawn_enemy(Vector2(270, 46))
		game.simulation.spawn_enemy(Vector2(38, 126))
		game.simulation.spawn_enemy(Vector2(245, 137))
		await _tree.physics_frame
		game.simulation.fire()
		await _tree.process_frame
		await RenderingServer.frame_post_draw
		_save_image("zombie_outbreak")
		print("ZOMBIE CAPTURE OK")


func _test_input(game: ZombieOutbreak) -> void:
	var before: Vector2 = game.simulation.player
	Input.action_press("move_right")
	await _tree.create_timer(0.15).timeout
	Input.action_release("move_right")
	_check(game.simulation.player.x > before.x + 2, "Input de movimiento llega a la simulacion")
	var mouse := InputEventMouseMotion.new()
	mouse.position = (
		(game.simulation.player + Vector2(28, 0))
		* game.get_viewport_rect().size
		/ Vector2(320, 180)
	)
	game.get_viewport().push_input(mouse, true)
	var enemy: OutbreakEnemy = game.simulation.spawn_enemy(game.simulation.player + Vector2(22, 0))
	enemy.speed = 0
	Input.action_press("zombie_fire")
	await _tree.create_timer(0.3).timeout
	Input.action_release("zombie_fire")
	_check(
		game.simulation.kills >= 1,
		(
			"Apuntado y disparo: mira %s, balas %d, objetivo %s, jugador %s, viewport %s"
			% [
				game.simulation.aim,
				game.simulation.ammo,
				enemy.position,
				game.simulation.player,
				game.get_viewport_rect().size
			]
		)
	)
	Input.action_press("zombie_reload")
	await _tree.physics_frame
	Input.action_release("zombie_reload")
	await _tree.create_timer(1.3).timeout
	_check(game.simulation.ammo == 12, "Input de recarga rellena el cargador")


func _capture_image(id: String) -> void:
	if "--capture" not in OS.get_cmdline_user_args() or DisplayServer.get_name() == "headless":
		return
	await _tree.create_timer(0.35).timeout
	await _tree.process_frame
	await RenderingServer.frame_post_draw
	_save_image(id)


func _save_image(id: String) -> void:
	DirAccess.make_dir_recursive_absolute("res://docs/images")
	var image: Image = _tree.root.get_texture().get_image()
	image.save_png("res://docs/images/%s.png" % id)


func _find_game() -> ZombieOutbreak:
	for child: Node in _tree.current_scene.get_children():
		if child is ZombieOutbreak:
			return child as ZombieOutbreak
	return null


func _wait_scene(path: String) -> bool:
	var deadline: int = Time.get_ticks_msec() + 5000
	while Time.get_ticks_msec() < deadline:
		await _tree.process_frame
		if _tree.current_scene != null and _tree.current_scene.scene_file_path == path:
			return true
	_fail("No abrio %s" % path)
	return false


func _check(condition: bool, message: String) -> void:
	if not condition:
		_errors.append(message)


func _fail(message: String) -> void:
	printerr("ZOMBIE FLOW FAIL: ", message)
	_tree.quit(1)
