class_name OutbreakAudio
extends RefCounted
## Sintesis PCM original de baja latencia, sin descargas ni efectos de bus.

const SAMPLE_RATE: int = 22050


static func make_effect(cue: StringName) -> AudioStreamWAV:
	var duration: float = 0.13
	var frequency: float = 170.0
	match cue:
		&"reload":
			duration = 0.22
			frequency = 740.0
		&"loaded":
			frequency = 920.0
		&"heal":
			duration = 0.3
			frequency = 660.0
		&"hurt":
			duration = 0.2
			frequency = 90.0
		&"dash":
			frequency = 330.0
		&"hit":
			frequency = 260.0
	var count: int = int(duration * SAMPLE_RATE)
	var bytes: PackedByteArray = []
	bytes.resize(count * 2)
	var rng := RandomNumberGenerator.new()
	rng.seed = 2468
	for index: int in count:
		var t: float = float(index) / SAMPLE_RATE
		var envelope: float = pow(1.0 - t / duration, 3.0)
		var tone: float = sin(TAU * frequency * t * (1.0 + t))
		var noise: float = rng.randf_range(-1.0, 1.0)
		var sample: float = tone * 0.2 + noise * 0.1
		if cue == &"shot":
			sample = noise * 0.38 + sin(TAU * 75.0 * t) * 0.2
		if cue == &"heal" or cue == &"loaded":
			sample = tone * 0.28
		bytes.encode_s16(index * 2, int(clampf(sample * envelope, -1.0, 1.0) * 32767))
	return _stream(bytes)


static func make_music() -> AudioStreamWAV:
	var count: int = SAMPLE_RATE * 4
	var bytes: PackedByteArray = []
	bytes.resize(count * 2)
	var notes: Array[float] = [220.0, 261.63, 329.63, 293.66, 220.0, 196.0, 164.81, 196.0]
	for index: int in count:
		var t: float = float(index) / SAMPLE_RATE
		var beat: int = int(t * 4.0)
		var frequency: float = notes[beat % notes.size()]
		var envelope: float = exp(-fmod(t, 0.25) * 18.0)
		var pulse: float = 1.0 if sin(TAU * frequency * t) > 0.0 else -1.0
		var bass: float = sin(TAU * 55 * t) * 0.045
		var sample: float = pulse * envelope * 0.035 + bass
		bytes.encode_s16(index * 2, int(sample * 32767))
	var stream: AudioStreamWAV = _stream(bytes)
	stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
	stream.loop_end = count
	return stream


static func _stream(bytes: PackedByteArray) -> AudioStreamWAV:
	var result := AudioStreamWAV.new()
	result.format = AudioStreamWAV.FORMAT_16_BITS
	result.mix_rate = SAMPLE_RATE
	result.data = bytes
	return result
