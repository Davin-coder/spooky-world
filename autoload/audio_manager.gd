extends Node
## Autoload "AudioManager": música de fondo y efectos de sonido.
##
## Uso:
##   AudioManager.play_music(preload("res://assets/audio/music/hub_theme.ogg"))
##   AudioManager.play_sfx(preload("res://assets/audio/sfx/pumpkin_catch_pop.wav"))
##
##   const HIT_SFX: Array[AudioStream] = [preload("res://.../hit_1.mp3"), preload(...)]
##   AudioManager.play_random_sfx(HIT_SFX, 0.08)  # uno al azar, sin repetir seguido
##
## Buses: "Music" y "SFX" (default_bus_layout.tres). Si un bus no existe,
## se usa "Master" para no romper el juego.

const SFX_POOL_SIZE: int = 8

var _music_player: AudioStreamPlayer
var _sfx_players: Array[AudioStreamPlayer] = []
var _next_sfx: int = 0
## Último efecto que sonó de cada lista de [method play_random_sfx]. La clave
## es la lista misma (los Array se comparan por contenido).
var _last_random_sfx: Dictionary[Array, AudioStream] = {}


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_music_player = AudioStreamPlayer.new()
	_music_player.bus = _bus_or_master(&"Music")
	add_child(_music_player)
	for i: int in SFX_POOL_SIZE:
		var player := AudioStreamPlayer.new()
		player.bus = _bus_or_master(&"SFX")
		add_child(player)
		_sfx_players.append(player)


## Reproduce música en loop. Si ya suena la misma pista, no la reinicia (solo
## ajusta el volumen). [param from_position] es el segundo donde empieza;
## [param volume_db] se suma al bus "Music" (negativo = más bajo).
func play_music(stream: AudioStream, from_position: float = 0.0, volume_db: float = 0.0) -> void:
	if stream == null:
		return
	_music_player.volume_db = volume_db
	if _music_player.stream == stream and _music_player.playing:
		return
	_music_player.stream = stream
	_music_player.play(from_position)


func stop_music() -> void:
	_music_player.stop()
	_music_player.stream = null


## Reproduce un efecto. Usa un pool para que varios sonidos se superpongan.
## El tono es [param base_pitch] ± [param pitch_variation] al azar;
## [param volume_db] se suma al bus "SFX" (negativo = más bajo).
func play_sfx(
	stream: AudioStream,
	pitch_variation: float = 0.0,
	volume_db: float = 0.0,
	base_pitch: float = 1.0,
) -> void:
	if stream == null:
		return
	var player: AudioStreamPlayer = _sfx_players[_next_sfx]
	_next_sfx = (_next_sfx + 1) % SFX_POOL_SIZE
	player.stream = stream
	# Los reproductores se reutilizan: hay que fijar volumen y tono en cada uso.
	player.volume_db = volume_db
	player.pitch_scale = base_pitch + randf_range(-pitch_variation, pitch_variation)
	player.play()


## Reproduce un efecto al azar de [param streams]. Si la lista tiene más de
## uno, nunca repite dos veces seguidas el mismo. Parámetros como [method play_sfx].
func play_random_sfx(
	streams: Array[AudioStream],
	pitch_variation: float = 0.0,
	volume_db: float = 0.0,
	base_pitch: float = 1.0,
) -> void:
	if streams.is_empty():
		return
	var candidates: Array[AudioStream] = streams.duplicate()
	if candidates.size() > 1 and _last_random_sfx.has(streams):
		candidates.erase(_last_random_sfx[streams])
	var stream: AudioStream = candidates.pick_random()
	_last_random_sfx[streams] = stream
	play_sfx(stream, pitch_variation, volume_db, base_pitch)


func _bus_or_master(bus_name: StringName) -> StringName:
	return bus_name if AudioServer.get_bus_index(bus_name) != -1 else &"Master"
