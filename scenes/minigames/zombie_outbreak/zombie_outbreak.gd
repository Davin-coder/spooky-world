class_name ZombieOutbreak
extends Minigame
## Ultima guardia: arcade cenital de zombis. Integracion y seccion: Dev 1.

const LOGICAL_SIZE: Vector2 = Vector2(320, 180)
const CUES: Array[StringName] = [&"shot", &"reload", &"loaded", &"hit", &"hurt", &"dash", &"heal"]

@export_group("Accesibilidad")
@export var reduced_motion: bool = false
@export var music_enabled: bool = true

@export_group("Balance")
@export var tuning: OutbreakTuning = OutbreakTuning.new()

var simulation: OutbreakSimulation = OutbreakSimulation.new()
var _paused: bool = false
var _pointer: Vector2 = Vector2(220, 99)
var _sounds: Dictionary[StringName, AudioStream] = {}
var _music: AudioStream

@onready var _arena: OutbreakArena = %Arena


func _ready() -> void:
	_arena.simulation = simulation
	simulation.points_earned.connect(add_score)
	simulation.sound_requested.connect(_on_sound_requested)
	simulation.defeated.connect(end_game)
	for cue: StringName in CUES:
		var path: String = "res://assets/audio/sfx/zombie_outbreak_%s.wav" % cue
		_sounds[cue] = (
			load(path) as AudioStream
			if ResourceLoader.exists(path)
			else OutbreakAudio.make_effect(cue)
		)
	var music_path: String = "res://assets/audio/music/zombie_outbreak_loop.ogg"
	_music = (
		load(music_path) as AudioStream
		if ResourceLoader.exists(music_path)
		else OutbreakAudio.make_music()
	)


func _exit_tree() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	AudioManager.stop_music()


func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT and is_node_ready() and is_running:
		pause_game(true)


func _physics_process(delta: float) -> void:
	if not is_running:
		return
	_arena.cursor = _pixel_mouse()
	if _paused:
		return
	simulation.step(
		delta,
		Input.get_vector("move_left", "move_right", "move_up", "move_down"),
		_arena.cursor,
		Input.is_action_pressed("zombie_fire"),
		Input.is_action_just_pressed("zombie_reload"),
		Input.is_action_just_pressed("zombie_dash")
	)
	_arena.time_left = get_time_left()
	_arena.score_value = score
	_arena.position = Vector2.ZERO
	if simulation.shake_left > 0 and not reduced_motion:
		_arena.position = Vector2(int(simulation.elapsed * 40) % 3 - 1, 0)


func _input(event: InputEvent) -> void:
	var mouse := event as InputEventMouse
	if mouse:
		_pointer = mouse.position * LOGICAL_SIZE / get_viewport_rect().size
	if not is_running:
		return
	if event.is_action_pressed("back"):
		pause_game(not _paused)
		get_viewport().set_input_as_handled()
	elif _paused and event.is_action_pressed("ui_accept"):
		pause_game(false)
		get_viewport().set_input_as_handled()
	elif _paused and event.is_action_pressed("zombie_fire"):
		var at: Vector2 = _pixel_mouse()
		if OutbreakArena.RESUME_RECT.has_point(at):
			pause_game(false)
		elif OutbreakArena.EXIT_RECT.has_point(at):
			exit_requested.emit()
		get_viewport().set_input_as_handled()


## Pausa local: simulacion y reloj se congelan juntos, sin pausar los autoloads.
func pause_game(paused: bool) -> void:
	_paused = paused
	set_game_paused(paused)
	_arena.paused = paused
	_arena.position = Vector2.ZERO
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE if paused else Input.MOUSE_MODE_HIDDEN


func _on_start() -> void:
	simulation.tuning = tuning
	simulation.reset()
	pause_game(false)
	_arena.ended = false
	_arena.score_value = 0
	_arena.time_left = duration_sec
	if music_enabled:
		AudioManager.play_music(_music)


func _on_end() -> void:
	simulation.active = false
	_arena.ended = true
	_arena.time_left = get_time_left()
	_arena.score_value = score
	_arena.position = Vector2.ZERO
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	AudioManager.stop_music()


func _on_sound_requested(cue: StringName) -> void:
	if _sounds.has(cue):
		AudioManager.play_sfx(_sounds[cue], 0.04)


func _pixel_mouse() -> Vector2:
	return _pointer
