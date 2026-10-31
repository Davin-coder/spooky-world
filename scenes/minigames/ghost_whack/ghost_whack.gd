extends Minigame
## Ghost Whack: haz clic en los fantasmas que aparecen en las ventanas.
## No toques a los fantasmas amigos (naranjas). Dueño: Dev 1.

const GHOST_SCENE: PackedScene = preload("res://scenes/minigames/ghost_whack/ghost.tscn")
## Golpes de diseño: suena uno al azar, sin repetir seguido.
const HIT_SFX: Array[AudioStream] = [
	preload("res://assets/audio/sfx/hits/1.mp3"),
	preload("res://assets/audio/sfx/hits/5.mp3"),
	preload("res://assets/audio/sfx/hits/9.mp3"),
	preload("res://assets/audio/sfx/hits/11.mp3"),
	preload("res://assets/audio/sfx/hits/13.mp3"),
]

@export_group("Dificultad")
@export var spawn_interval_start: float = 0.9
@export var spawn_interval_end: float = 0.4
@export var lifetime_start: float = 1.4
@export var lifetime_end: float = 0.6
@export_range(0.0, 1.0) var friendly_chance: float = 0.2

@export_group("Puntaje")
@export var points_per_ghost: int = 10
@export var friendly_penalty: int = 20

@export_group("Audio")
## Variación de tono al azar de cada golpe (0.08 = ±8 %).
@export_range(0.0, 0.5) var hit_pitch_variation: float = 0.08
## Volumen de los golpes sobre el bus SFX. Vienen normalizados a 0 dBFS.
@export_range(-40.0, 6.0) var hit_volume_db: float = -3.0
## Tono fijo al golpear un fantasma amigo: más grave = error.
@export_range(0.3, 1.0) var friendly_pitch: float = 0.7

## Ventana -> fantasma que la ocupa ahora.
var _occupied: Dictionary[Marker2D, Ghost] = {}

@onready var _spots: Node2D = %Spots
@onready var _ghosts: Node2D = %Ghosts
@onready var _spawn_timer: Timer = %SpawnTimer


func _ready() -> void:
	# Necesario para que Area2D reciba clics del mouse.
	get_viewport().physics_object_picking = true
	_spawn_timer.timeout.connect(_spawn_ghost)


func _on_start() -> void:
	_clear_ghosts()
	_spawn_timer.start(spawn_interval_start)


func _on_end() -> void:
	_spawn_timer.stop()
	_clear_ghosts()


func _spawn_ghost() -> void:
	var free_spots: Array[Marker2D] = []
	for child: Node in _spots.get_children():
		var marker := child as Marker2D
		if marker and not _occupied.has(marker):
			free_spots.append(marker)
	if free_spots.is_empty():
		return
	var spot: Marker2D = free_spots.pick_random()
	var progress: float = get_progress()
	var ghost := GHOST_SCENE.instantiate() as Ghost
	ghost.is_friendly = randf() < friendly_chance
	ghost.lifetime = lerpf(lifetime_start, lifetime_end, progress)
	ghost.position = spot.position
	ghost.whacked.connect(_on_ghost_whacked)
	ghost.tree_exited.connect(func() -> void: _occupied.erase(spot))
	_occupied[spot] = ghost
	_ghosts.add_child(ghost)
	_spawn_timer.wait_time = lerpf(spawn_interval_start, spawn_interval_end, progress)


func _on_ghost_whacked(ghost: Ghost) -> void:
	if ghost.is_friendly:
		add_score(-friendly_penalty)
		AudioManager.play_random_sfx(HIT_SFX, 0.0, hit_volume_db, friendly_pitch)
	else:
		add_score(points_per_ghost)
		AudioManager.play_random_sfx(HIT_SFX, hit_pitch_variation, hit_volume_db)


func _clear_ghosts() -> void:
	for child: Node in _ghosts.get_children():
		child.queue_free()
