extends Node
## Autoload "AudioManager": música de fondo y efectos de sonido.
##
## Uso:
##   AudioManager.play_music(preload("res://assets/audio/music/hub_theme.ogg"))
##   AudioManager.play_sfx(preload("res://assets/audio/sfx/pumpkin_catch_pop.wav"))
##
## Buses: "Music" y "SFX" (default_bus_layout.tres). Si un bus no existe,
## se usa "Master" para no romper el juego.

const SFX_POOL_SIZE: int = 8

var _music_player: AudioStreamPlayer
var _sfx_players: Array[AudioStreamPlayer] = []
var _next_sfx: int = 0


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


## Reproduce música en loop. Si ya suena la misma pista, no la reinicia.
func play_music(stream: AudioStream) -> void:
	if stream == null:
		return
	if _music_player.stream == stream and _music_player.playing:
		return
	_music_player.stream = stream
	_music_player.play()


func stop_music() -> void:
	_music_player.stop()
	_music_player.stream = null


## Reproduce un efecto. Usa un pool para que varios sonidos se superpongan.
func play_sfx(stream: AudioStream, pitch_variation: float = 0.0) -> void:
	if stream == null:
		return
	var player: AudioStreamPlayer = _sfx_players[_next_sfx]
	_next_sfx = (_next_sfx + 1) % SFX_POOL_SIZE
	player.stream = stream
	player.pitch_scale = 1.0 + randf_range(-pitch_variation, pitch_variation)
	player.play()


func _bus_or_master(bus_name: StringName) -> StringName:
	return bus_name if AudioServer.get_bus_index(bus_name) != -1 else &"Master"
