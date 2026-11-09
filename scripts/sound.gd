extends Node
class_name SoundSynth
## Semua suara disintesis prosedural ke AudioStreamWAV (16-bit PCM)
## saat pertama dipakai, lalu di-cache — tanpa file audio sama sekali.
## Nada dibuat dari gelombang sinus (atau kotak untuk bunyi gagal)
## dengan envelope decay; sapuan frekuensi dipakai untuk suara tuang.

const MIX_RATE := 22050
const BGM_RATE := 11025
const BGM_LENGTH := 8.0

var muted: bool = false
var sfx_volume: float = 1.0
var bgm_volume: float = 1.0
var _cache: Dictionary = {}
var _bgm_player: AudioStreamPlayer = null


func play(sound_name: String) -> void:
	if muted:
		return
	if not _cache.has(sound_name):
		_cache[sound_name] = _build(sound_name)
	var stream: AudioStreamWAV = _cache[sound_name]
	if stream == null:
		return
	var p := AudioStreamPlayer.new()
	p.stream = stream
	p.volume_db = linear_to_db(maxf(sfx_volume, 0.001))
	p.finished.connect(p.queue_free)
	add_child(p)
	p.play()


## Musik latar: loop 8 detik prosedural (pad akor + melodi marimba
## pentatonik), diputar terus oleh satu player persisten.
func play_bgm() -> void:
	if _bgm_player != null and _bgm_player.playing:
		return
	var stream := bgm_stream()
	if stream == null:
		return
	_bgm_player = AudioStreamPlayer.new()
	_bgm_player.stream = stream
	_bgm_player.volume_db = -16.0 + linear_to_db(maxf(bgm_volume, 0.001))
	add_child(_bgm_player)
	_bgm_player.play()


## Ubah volume BGM yang sedang diputar (dipakai slider Pengaturan).
func set_bgm_volume(value: float) -> void:
	bgm_volume = clampf(value, 0.0, 1.0)
	if _bgm_player != null:
		_bgm_player.volume_db = -16.0 + linear_to_db(maxf(bgm_volume, 0.001))


func stop_bgm() -> void:
	if _bgm_player == null:
		return
	_bgm_player.stop()
	_bgm_player.queue_free()
	_bgm_player = null


func bgm_stream() -> AudioStreamWAV:
	if not _cache.has("__bgm"):
		_cache["__bgm"] = _build_bgm()
	return _cache["__bgm"]


func is_bgm_playing() -> bool:
	return _bgm_player != null and _bgm_player.playing


func _build(sound_name: String) -> AudioStreamWAV:
	match sound_name:
		"select":
			return _make_wav([[900.0, 900.0]], 0.06, "sine", 0.5)
		"click":
			return _make_wav([[880.0, 880.0]], 0.05, "sine", 0.4)
		"pour":
			return _make_wav([[1047.0, 784.0]], 0.16, "sine", 0.55)
		"complete":
			return _make_wav([[784.0, 784.0], [1047.0, 1047.0], [1319.0, 1319.0]], 0.10, "sine", 0.5)
		"invalid":
			return _make_wav([[150.0, 120.0]], 0.16, "square", 0.4)
		"win":
			return _make_wav([[523.0, 523.0], [659.0, 659.0], [784.0, 784.0], [1047.0, 1047.0], [1319.0, 1319.0], [1568.0, 1568.0]], 0.12, "sine", 0.55)
	return null


## Loop BGM 8 detik: pad akor Am7–Fmaj7–Cmaj7–G6 (2 detik tiap
## akor) + melodi pentatonik marimba (satu nada tiap 0,5 detik).
func _build_bgm() -> AudioStreamWAV:
	var chords: Array = [
		[110.0, 130.81, 164.81, 196.0],
		[87.31, 110.0, 130.81, 164.81],
		[130.81, 164.81, 196.0, 246.94],
		[98.0, 123.47, 146.83, 164.81],
	]
	var melody: Array = [523.25, 659.25, 783.99, 880.0, 783.99, 659.25, 587.33, 523.25,
		659.25, 783.99, 880.0, 1046.5, 880.0, 783.99, 659.25, 587.33]
	var total := int(BGM_RATE * BGM_LENGTH)
	var data := PackedByteArray()
	data.resize(total * 2)
	var chord_phases: Array[float] = [0.0, 0.0, 0.0, 0.0]
	var melody_phase := 0.0
	for i in range(total):
		var t := float(i) / float(BGM_RATE)
		var chord_idx := int(t / 2.0) % chords.size()
		var chord: Array = chords[chord_idx]
		var chord_t := fmod(t, 2.0)
		var attack := clampf(chord_t / 0.4, 0.0, 1.0)
		var release := clampf((2.0 - chord_t) / 0.4, 0.0, 1.0)
		var pad := 0.0
		for n in range(chord.size()):
			pad += sin(chord_phases[n]) * 0.11
			chord_phases[n] += TAU * float(chord[n]) / BGM_RATE
		pad *= attack * release
		var mel_idx := int(t / 0.5) % melody.size()
		var mel_age := fmod(t, 0.5)
		var mel_freq: float = melody[mel_idx]
		var mel := sin(melody_phase) * exp(-6.0 * mel_age) * 0.28
		melody_phase += TAU * mel_freq / BGM_RATE
		var v := int(clampf(pad + mel, -1.0, 1.0) * 32767.0)
		data.encode_s16(i * 2, v)
	var wav := AudioStreamWAV.new()
	wav.format = AudioStreamWAV.FORMAT_16_BITS
	wav.mix_rate = BGM_RATE
	wav.stereo = false
	wav.data = data
	wav.loop_mode = AudioStreamWAV.LOOP_FORWARD
	wav.loop_begin = 0
	wav.loop_end = total
	return wav


func _make_wav(notes: Array, note_dur: float, wave: String, volume: float) -> AudioStreamWAV:
	var count := int(MIX_RATE * note_dur)
	var total := count * notes.size()
	var data := PackedByteArray()
	data.resize(total * 2)
	for n in range(notes.size()):
		var f0: float = notes[n][0]
		var f1: float = notes[n][1]
		var phase := 0.0
		for i in range(count):
			var frac := float(i) / float(count)
			var freq := lerpf(f0, f1, frac)
			var env := exp(-3.0 * frac)
			var s := 0.0
			if wave == "square":
				s = 0.6 if sin(phase) >= 0.0 else -0.6
			else:
				s = sin(phase)
			phase += TAU * freq / MIX_RATE
			var v := int(clampf(s * env * volume, -1.0, 1.0) * 32767.0)
			data.encode_s16((n * count + i) * 2, v)
	var wav := AudioStreamWAV.new()
	wav.format = AudioStreamWAV.FORMAT_16_BITS
	wav.mix_rate = MIX_RATE
	wav.stereo = false
	wav.data = data
	return wav
