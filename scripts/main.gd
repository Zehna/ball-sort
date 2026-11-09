extends Control
## Ball Sort Warna — kontroler game.
## Tap tabung untuk pilih, tap tabung lain untuk tuang.
## Tuang memindahkan seluruh rangkaian bola warna sama di atas
## (sebatas ruang kosong di tabung tujuan). Menang kalau tiap tabung
## yang terisi penuh dengan satu warna.
## Fase 1: 30 level (semua terverifikasi solver BFS), level select,
## save progres (ConfigFile user://), hint (solver BFS di runtime),
## deteksi deadlock (tidak ada langkah valid).
## Fase 3: mode Klasik/Waktu/Sulit/Harian (GameState autoload),
## timer + skor, batas langkah, papan harian dari seed tanggal,
## pause menu + panel gagal. Save dipusatkan di GameState.

# Level: tiap tabung = Array warna (indeks 0 = paling bawah).
# Warna: 0 merah, 1 hijau, 2 biru, 3 kuning, 4 ungu.
# L1-3 buatan tangan; L4-30 digenerate acak (seed tetap) dan
# diverifikasi solvable pakai solver BFS dengan aturan tuang yang sama.
const LEVELS: Array = [
	[[0, 1, 0, 2], [1, 2, 1, 0], [2, 0, 2, 1], [], []],
	[[0, 1, 2, 3], [1, 2, 3, 0], [2, 3, 0, 1], [3, 0, 1, 2], [], []],
	[[0, 1, 2, 3], [1, 2, 3, 4], [2, 3, 4, 0], [3, 4, 0, 1], [4, 0, 1, 2], [], []],
	[[0, 1, 2, 0], [1, 2, 2, 0], [1, 2, 1, 0], [], []],
	[[0, 2, 1, 1], [0, 2, 1, 0], [2, 2, 0, 1], [], []],
	[[2, 0, 2, 1], [2, 1, 2, 1], [0, 0, 0, 1], [], []],
	[[2, 0, 1, 0], [1, 0, 1, 2], [1, 2, 0, 2], [], []],
	[[2, 0, 1, 0], [1, 1, 0, 2], [2, 2, 0, 1], [], []],
	[[1, 0, 2, 0], [0, 1, 0, 2], [1, 2, 2, 1], [], []],
	[[0, 2, 0, 1], [0, 2, 1, 1], [2, 1, 2, 0], [], []],
	[[2, 3, 1, 0], [1, 3, 2, 1], [2, 0, 0, 0], [1, 3, 2, 3], [], []],
	[[3, 1, 1, 0], [0, 2, 0, 3], [2, 1, 1, 2], [3, 3, 0, 2], [], []],
	[[0, 3, 1, 2], [2, 0, 3, 1], [1, 0, 2, 0], [1, 3, 3, 2], [], []],
	[[1, 3, 3, 0], [1, 3, 2, 1], [2, 2, 0, 0], [2, 0, 3, 1], [], []],
	[[3, 2, 2, 0], [3, 1, 0, 1], [3, 0, 3, 0], [1, 2, 2, 1], [], []],
	[[2, 1, 3, 0], [3, 2, 1, 3], [3, 0, 1, 2], [1, 0, 2, 0], [], []],
	[[1, 0, 0, 1], [2, 0, 1, 2], [1, 3, 3, 0], [2, 2, 3, 3], [], []],
	[[3, 3, 2, 0], [1, 1, 2, 2], [0, 1, 1, 3], [2, 0, 3, 0], [], []],
	[[1, 2, 2, 3], [1, 2, 0, 3], [1, 0, 1, 3], [3, 2, 0, 0], [], []],
	[[2, 0, 3, 3], [1, 0, 1, 0], [2, 3, 3, 2], [0, 1, 2, 1], [], []],
	[[1, 1, 2, 4], [3, 3, 0, 4], [4, 3, 0, 3], [0, 1, 0, 1], [4, 2, 2, 2], [], []],
	[[1, 3, 2, 0], [3, 4, 0, 4], [3, 1, 1, 4], [2, 0, 2, 1], [0, 3, 2, 4], [], []],
	[[3, 2, 0, 1], [0, 4, 1, 2], [2, 1, 4, 0], [0, 3, 4, 3], [2, 1, 4, 3], [], []],
	[[0, 2, 1, 0], [4, 4, 1, 2], [4, 3, 1, 3], [3, 1, 0, 2], [0, 2, 4, 3], [], []],
	[[1, 4, 0, 3], [4, 4, 2, 3], [1, 4, 0, 0], [1, 2, 2, 3], [1, 0, 2, 3], [], []],
	[[1, 2, 1, 3], [2, 4, 2, 3], [0, 1, 4, 3], [0, 4, 0, 1], [0, 2, 3, 4], [], []],
	[[0, 2, 4, 4], [1, 2, 1, 4], [1, 2, 3, 3], [1, 0, 0, 3], [4, 0, 3, 2], [], []],
	[[0, 1, 1, 0], [1, 2, 2, 3], [3, 4, 3, 2], [4, 0, 3, 2], [1, 0, 4, 4], [], []],
	[[4, 0, 0, 2], [3, 3, 2, 4], [0, 3, 4, 2], [1, 2, 4, 1], [3, 1, 0, 1], [], []],
	[[1, 0, 2, 1], [0, 2, 0, 4], [4, 4, 0, 3], [4, 2, 3, 1], [3, 2, 3, 1], [], []],
]
const MIN_MOVES: Array[int] = [10, 13, 16, 10, 8, 8, 11, 8, 9, 9, 12, 11, 13, 11, 13, 13, 10, 10, 12, 11, 12, 16, 17, 16, 15, 17, 14, 14, 15, 16]
const MAX_EXTRA_TUBES: int = 2
const HINT_STATE_CAP := 80000

var current_level: int = 0
var tubes: Array = []
var selected_index: int = -1
var moves: int = 0
var undo_stack: Array = []
var extra_tubes_left: int = MAX_EXTRA_TUBES
var deadlocked: bool = false
var animating: bool = false
# Fase 3: mode
var mode: String = "classic"
var time_left: float = 0.0
var timed_score: int = 0
var timer_running: bool = false
var paused: bool = false
var move_limit: int = 0
var current_board: Array = []
var current_board_min: int = 0
# Progres tersimpan
var unlocked: int = 1
var saved_stars: Array[int] = []
var saved_best: Array[int] = []
var saved_hard_stars: Array[int] = []
var saved_hard_best: Array[int] = []
var level_buttons: Array = []

@onready var tubes_container: Control = $TubesContainer
@onready var pour_fx: PourFx = $PourFx
@onready var sound: SoundSynth = $SoundSynth
@onready var level_label: Label = $LevelPill/LevelLabel
@onready var moves_label: Label = $MovesPill/MovesLabel
@onready var message_label: Label = $MessageLabel
@onready var level_button: Button = $LevelButton
@onready var undo_button: Button = $UndoButton
@onready var add_tube_button: Button = $AddTubeButton
@onready var hint_button: Button = $HintButton
@onready var restart_button: Button = $RestartButton
@onready var win_panel: PanelContainer = $WinPanel
@onready var stars_label: Label = $WinPanel/VBox/StarsLabel
@onready var win_label: Label = $WinPanel/VBox/WinLabel
@onready var win_info_label: Label = $WinPanel/VBox/WinInfoLabel
@onready var next_button: Button = $WinPanel/VBox/NextButton
@onready var select_level_button: Button = $WinPanel/VBox/SelectLevelButton
@onready var level_select_panel: PanelContainer = $LevelSelectPanel
@onready var select_summary: Label = $LevelSelectPanel/SelectVBox/SelectSummary
@onready var select_grid: GridContainer = $LevelSelectPanel/SelectVBox/SelectGrid
@onready var sound_button: Button = $LevelSelectPanel/SelectVBox/SoundButton
@onready var select_title: Label = $LevelSelectPanel/SelectVBox/SelectTitle
@onready var pause_button: Button = $PauseButton
@onready var pause_panel: PanelContainer = $PausePanel
@onready var pause_resume_button: Button = $PausePanel/VBox/ResumeButton
@onready var pause_restart_button: Button = $PausePanel/VBox/PauseRestartButton
@onready var pause_menu_button: Button = $PausePanel/VBox/PauseMenuButton
@onready var fail_panel: PanelContainer = $FailPanel
@onready var fail_label: Label = $FailPanel/VBox/FailLabel
@onready var fail_info_label: Label = $FailPanel/VBox/FailInfoLabel
@onready var fail_retry_button: Button = $FailPanel/VBox/FailRetryButton
@onready var fail_menu_button: Button = $FailPanel/VBox/FailMenuButton


func _ready() -> void:
	mode = GameState.mode
	undo_button.pressed.connect(_on_undo_pressed)
	add_tube_button.pressed.connect(_on_add_tube_pressed)
	hint_button.pressed.connect(_on_hint_pressed)
	restart_button.pressed.connect(_on_restart_pressed)
	next_button.pressed.connect(_on_next_pressed)
	select_level_button.pressed.connect(_on_top_button_pressed)
	level_button.pressed.connect(_on_top_button_pressed)
	sound_button.pressed.connect(_on_sound_toggled)
	pause_button.pressed.connect(_on_pause_pressed)
	pause_resume_button.pressed.connect(_on_pause_resume_pressed)
	pause_restart_button.pressed.connect(_on_pause_restart_pressed)
	pause_menu_button.pressed.connect(_go_to_menu)
	fail_retry_button.pressed.connect(_on_fail_retry_pressed)
	fail_menu_button.pressed.connect(_go_to_menu)
	_load_progress()
	if mode == "timed" or mode == "daily":
		level_button.text = "Menu"
		if mode == "timed":
			timed_score = 0
		_start_generated_board()
	else:
		_show_level_select()


# ------------------------------------------------------------------ progres
func _load_progress() -> void:
	GameState.load_all()
	unlocked = GameState.unlocked
	saved_stars = GameState.stars.duplicate()
	saved_best = GameState.best.duplicate()
	saved_hard_stars = GameState.hard_stars.duplicate()
	saved_hard_best = GameState.hard_best.duplicate()
	sound.muted = GameState.muted
	_update_sound_button()


func _save_progress() -> void:
	GameState.unlocked = unlocked
	GameState.stars = saved_stars.duplicate()
	GameState.best = saved_best.duplicate()
	GameState.hard_stars = saved_hard_stars.duplicate()
	GameState.hard_best = saved_hard_best.duplicate()
	GameState.muted = sound.muted
	GameState.save_all()


func _update_sound_button() -> void:
	sound_button.text = "Suara: Mati" if sound.muted else "Suara: Nyala"


func _on_sound_toggled() -> void:
	sound.muted = not sound.muted
	_update_sound_button()
	_save_progress()
	sound.play("click")


func _total_stars() -> int:
	var total := 0
	for v in saved_stars:
		total += v
	return total


func _total_hard_stars() -> int:
	var total := 0
	for v in saved_hard_stars:
		total += v
	return total


# -------------------------------------------------------------- level select
func _stars_text(n: int) -> String:
	return "★".repeat(n) + "☆".repeat(3 - n)


func _level_button_style(bg: Color) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = bg
	s.set_corner_radius_all(16)
	return s


func _build_level_select() -> void:
	for child in select_grid.get_children():
		child.queue_free()
	level_buttons.clear()
	var open_style := _level_button_style(Color(0.2, 0.23, 0.33, 1))
	var open_hover := _level_button_style(Color(0.27, 0.3, 0.42, 1))
	var open_pressed := _level_button_style(Color(0.15, 0.17, 0.25, 1))
	var locked_style := _level_button_style(Color(0.12, 0.13, 0.2, 1))
	var stars_arr := saved_hard_stars if mode == "hard" else saved_stars
	select_title.text = "Pilih Level — Mode Sulit" if mode == "hard" else "Pilih Level"
	for i in range(LEVELS.size()):
		var b := Button.new()
		b.custom_minimum_size = Vector2(120, 86)
		b.add_theme_font_size_override("font_size", 22)
		var is_open := i < unlocked
		b.text = "%d\n%s" % [i + 1, _stars_text(stars_arr[i]) if is_open else "☆☆☆"]
		b.disabled = not is_open
		if is_open:
			b.add_theme_stylebox_override("normal", open_style)
			b.add_theme_stylebox_override("hover", open_hover)
			b.add_theme_stylebox_override("pressed", open_pressed)
			b.add_theme_color_override("font_color", Color(1, 1, 1, 1))
		else:
			b.add_theme_stylebox_override("normal", locked_style)
			b.add_theme_color_override("font_color", Color(1, 1, 1, 0.35))
			b.add_theme_color_override("font_disabled_color", Color(1, 1, 1, 0.35))
		b.pressed.connect(_on_level_button_pressed.bind(i))
		select_grid.add_child(b)
		level_buttons.append(b)
	var total := _total_hard_stars() if mode == "hard" else _total_stars()
	select_summary.text = "Level terbuka: %d/%d  •  Bintang: %d/%d" % [
		unlocked, LEVELS.size(), total, LEVELS.size() * 3]


func _show_level_select() -> void:
	_deselect()
	win_panel.visible = false
	fail_panel.visible = false
	pause_panel.visible = false
	_build_level_select()
	level_select_panel.visible = true


func _on_top_button_pressed() -> void:
	sound.play("click")
	if mode == "timed" or mode == "daily":
		_go_to_menu()
	else:
		_show_level_select()


func _on_level_button_pressed(index: int) -> void:
	sound.play("click")
	level_select_panel.visible = false
	load_level(index)


# ------------------------------------------------------------------- gameplay
func load_level(index: int) -> void:
	current_level = index
	var def: Array = []
	for t in LEVELS[current_level]:
		def.append((t as Array).duplicate())
	if mode == "hard":
		move_limit = MIN_MOVES[current_level] + 3
	_reset_board(def)


func _reset_board(def: Array) -> void:
	undo_stack.clear()
	selected_index = -1
	moves = 0
	extra_tubes_left = MAX_EXTRA_TUBES
	deadlocked = false
	animating = false
	paused = false
	timer_running = false
	pour_fx.cancel()
	win_panel.visible = false
	fail_panel.visible = false
	pause_panel.visible = false
	message_label.text = ""
	_build_tubes(def)
	_update_labels()
	_check_deadlock()


func _build_tubes(state: Array) -> void:
	for child in tubes_container.get_children():
		child.queue_free()
	tubes.clear()
	selected_index = -1
	var count := state.size()
	var avail := size.x - 32.0
	var gap := 12.0
	var tube_w := minf(96.0, (avail - float(count - 1) * gap) / float(count))
	var total := float(count) * tube_w + float(count - 1) * gap
	var start_x := (size.x - total) * 0.5
	for i in range(count):
		var tube := Tube.new()
		tube.position = Vector2(start_x + float(i) * (tube_w + gap), 20)
		tube.size = Vector2(tube_w, 360)
		tube.set_balls(state[i])
		tube.tapped.connect(_on_tube_tapped)
		tubes_container.add_child(tube)
		tubes.append(tube)


func _current_balls() -> Array:
	var out: Array = []
	for t in tubes:
		out.append(t.balls.duplicate())
	return out


# ------------------------------------------------------- papan acak (timed/daily)
func _solution_length(balls_state: Array) -> int:
	## BFS penuh; kembalikan panjang solusi optimal, -1 kalau tidak
	## ada solusi / batas state tercapai. Dipakai untuk verifikasi
	## papan acak + bintang vs minimal di mode waktu/harian.
	if _is_win_state(balls_state):
		return 0
	var start_key := _state_key(balls_state)
	var queue: Array = [balls_state]
	var dist := {start_key: 0}
	var head := 0
	var visited := 1
	while head < queue.size():
		var s: Array = queue[head]
		head += 1
		var d: int = dist[_state_key(s)]
		for pour in _valid_pours(s):
			var ns := _apply_pour(s, pour)
			var k := _state_key(ns)
			if dist.has(k):
				continue
			dist[k] = d + 1
			visited += 1
			if visited > 30000:
				return -1
			if _is_win_state(ns):
				return d + 1
			queue.append(ns)
	return -1


func _generate_board(rng: RandomNumberGenerator, num_colors: int) -> Array:
	for attempt in range(50):
		var pool: Array[int] = []
		for c in range(num_colors):
			for k in range(Tube.CAPACITY):
				pool.append(c)
		var shuffled := pool.duplicate()
		for i in range(shuffled.size() - 1, 0, -1):
			var j := rng.randi_range(0, i)
			var tmp: int = shuffled[i]
			shuffled[i] = shuffled[j]
			shuffled[j] = tmp
		var board: Array = []
		for t in range(num_colors):
			var tube: Array[int] = []
			for k in range(Tube.CAPACITY):
				tube.append(shuffled[t * Tube.CAPACITY + k])
			board.append(tube)
		board.append([])
		board.append([])
		var min_moves := _solution_length(board)
		if min_moves >= 0:
			current_board_min = min_moves
			return board
	# Fallback: level klasik 1 (dijamin solvable).
	var fallback: Array = []
	for t in LEVELS[0]:
		fallback.append((t as Array).duplicate())
	current_board_min = MIN_MOVES[0]
	return fallback


func _start_generated_board() -> void:
	var rng := RandomNumberGenerator.new()
	if mode == "daily":
		rng.seed = GameState.daily_seed_for_today()
	else:
		rng.randomize()
	current_board = _generate_board(rng, 4)
	if mode == "timed":
		# Skor TIDAK direset di sini: _start_generated_board() juga dipanggil
		# tombol "Papan Berikutnya", dan skor harus akumulasi antar papan
		# dalam satu sesi waktu. Reset skor hanya di _ready (awal sesi).
		time_left = 90.0
	var def: Array = []
	for t in current_board:
		def.append((t as Array).duplicate())
	_reset_board(def)
	if mode == "timed":
		timer_running = true


func _reload_current_board() -> void:
	var def: Array = []
	for t in current_board:
		def.append((t as Array).duplicate())
	_reset_board(def)
	if mode == "timed":
		time_left = 90.0
		timer_running = true


func _process(delta: float) -> void:
	if mode != "timed" or not timer_running or paused:
		return
	if win_panel.visible or fail_panel.visible or pause_panel.visible or level_select_panel.visible:
		return
	time_left -= delta
	if time_left <= 0.0:
		time_left = 0.0
		timer_running = false
		_show_fail("Waktu Habis!", "Skor: %d  •  Terbaik: %d" % [timed_score, GameState.timed_best_score])
	_update_labels()


func _on_tube_tapped(tube) -> void:
	if win_panel.visible or fail_panel.visible or pause_panel.visible or level_select_panel.visible or animating:
		return
	var index := tubes.find(tube)
	if index == -1:
		return
	if selected_index == -1:
		if tube.is_empty():
			return
		selected_index = index
		tube.set_selected(true)
		sound.play("select")
		return
	if index == selected_index:
		tube.set_selected(false)
		selected_index = -1
		return
	_try_pour(selected_index, index)


func _tube_mouth(index: int) -> Vector2:
	var t = tubes[index]
	return tubes_container.position + t.position + Vector2(t.size.x * 0.5, 20.0)


func _try_pour(from_index: int, to_index: int) -> void:
	var src = tubes[from_index]
	var dst = tubes[to_index]
	var from_color: int = src.top_color()
	if dst.is_full():
		_show_message("Tabung tujuan sudah penuh!")
		sound.play("invalid")
		GameState.vibrate(40)
		_shake(src)
		_deselect()
		return
	if not dst.is_empty() and dst.top_color() != from_color:
		_show_message("Warna atas tidak cocok!")
		sound.play("invalid")
		GameState.vibrate(40)
		_shake(src)
		_deselect()
		return
	undo_stack.append(_snapshot())
	var space: int = Tube.CAPACITY - dst.balls.size()
	var n: int = mini(src.top_run(), space)
	var moving: Array[int] = []
	for k in range(n):
		moving.append(from_color)
	# Animasi dulu, commit belakangan: bola sumber disembunyikan
	# selama diterbangkan PourFx, input diblokir sampai selesai.
	_deselect()
	var from_mouth := _tube_mouth(from_index)
	var to_mouth := _tube_mouth(to_index)
	var ball_r: float = src.size.x * 0.5 - 8.0
	animating = true
	src.set_hidden_top(n)
	pour_fx.start_pour(from_mouth, to_mouth, moving, ball_r)
	await pour_fx.finished
	for k in range(n):
		src.balls.pop_back()
	for v in moving:
		dst.balls.append(v)
	src.set_hidden_top(0)
	moves += 1
	animating = false
	src.queue_redraw()
	dst.queue_redraw()
	_pop(dst)
	sound.play("pour")
	if dst.is_complete():
		sound.play("complete")
	GameState.vibrate(60)
	_update_labels()
	if _check_win():
		_show_win()
	elif mode == "hard" and moves >= move_limit:
		_show_fail("Langkah Habis!", "Minimal level ini: %d langkah" % MIN_MOVES[current_level])
	else:
		_check_deadlock()


func _snapshot() -> Dictionary:
	return {"balls": _current_balls(), "moves": moves, "extra": extra_tubes_left}


func _restore(snapshot: Dictionary) -> void:
	extra_tubes_left = int(snapshot["extra"])
	moves = int(snapshot["moves"])
	_build_tubes(snapshot["balls"])
	_update_labels()
	_check_deadlock()


func _on_undo_pressed() -> void:
	if animating:
		return
	if win_panel.visible or fail_panel.visible or pause_panel.visible or level_select_panel.visible:
		return
	if undo_stack.is_empty():
		_show_message("Tidak ada langkah untuk diurungkan.")
		return
	_deselect()
	_restore(undo_stack.pop_back())
	sound.play("click")
	_show_message("Langkah diurungkan.")


func _on_add_tube_pressed() -> void:
	if animating:
		return
	if win_panel.visible or fail_panel.visible or pause_panel.visible or level_select_panel.visible:
		return
	if extra_tubes_left <= 0:
		_show_message("Tabung tambahan sudah habis!")
		return
	undo_stack.append(_snapshot())
	extra_tubes_left -= 1
	var state := _current_balls()
	state.append([])
	_build_tubes(state)
	_update_labels()
	_check_deadlock()
	sound.play("click")
	_show_message("Tabung kosong ditambah!")


func _on_restart_pressed() -> void:
	if animating:
		return
	if win_panel.visible or fail_panel.visible or pause_panel.visible or level_select_panel.visible:
		return
	load_level(current_level)
	sound.play("click")
	_show_message("Level diulang dari awal.")


func _on_next_pressed() -> void:
	sound.play("click")
	match mode:
		"timed":
			_start_generated_board()
		"daily":
			_go_to_menu()
		_:
			if current_level + 1 >= LEVELS.size():
				load_level(0)
			else:
				load_level(current_level + 1)


# ------------------------------------------------------------------ gagal/jeda
func _show_fail(title: String, info: String) -> void:
	timer_running = false
	sound.play("invalid")
	GameState.vibrate(120)
	fail_label.text = title
	fail_info_label.text = info
	fail_panel.visible = true


func _on_fail_retry_pressed() -> void:
	sound.play("click")
	if mode == "timed" or mode == "daily":
		_reload_current_board()
	else:
		load_level(current_level)


func _on_pause_pressed() -> void:
	if animating or win_panel.visible or fail_panel.visible or level_select_panel.visible:
		return
	sound.play("click")
	paused = true
	pause_panel.visible = true


func _on_pause_resume_pressed() -> void:
	sound.play("click")
	paused = false
	pause_panel.visible = false


func _on_pause_restart_pressed() -> void:
	sound.play("click")
	paused = false
	pause_panel.visible = false
	if mode == "timed" or mode == "daily":
		_reload_current_board()
	else:
		load_level(current_level)


func _go_to_menu() -> void:
	get_tree().change_scene_to_file("res://scenes/menu.tscn")


func _deselect() -> void:
	if selected_index >= 0 and selected_index < tubes.size():
		tubes[selected_index].set_selected(false)
	selected_index = -1


func _check_win() -> bool:
	for t in tubes:
		if t.is_empty():
			continue
		if not t.is_complete():
			return false
	return true


func _show_win() -> void:
	timer_running = false
	if mode == "timed":
		timed_score += 1
		GameState.record_timed_score(timed_score)
		var tstars := 3 if moves <= current_board_min else (2 if moves <= current_board_min + 5 else 1)
		stars_label.text = "★".repeat(tstars) + "☆".repeat(3 - tstars)
		sound.play("win")
		GameState.vibrate(120)
		win_label.text = "Papan Selesai!"
		win_info_label.text = "Skor: %d  •  Terbaik: %d  •  Langkah: %d (min %d)" % [timed_score, GameState.timed_best_score, moves, current_board_min]
		next_button.text = "Papan Berikutnya"
		select_level_button.text = "Menu Utama"
		win_panel.visible = true
		return
	if mode == "daily":
		GameState.record_daily_win()
		var dstars := 3 if moves <= current_board_min else (2 if moves <= current_board_min + 5 else 1)
		stars_label.text = "★".repeat(dstars) + "☆".repeat(3 - dstars)
		sound.play("win")
		GameState.vibrate(120)
		win_label.text = "Tantangan Harian Selesai!"
		win_info_label.text = "Langkah: %d (min %d)  •  Streak: %d hari" % [moves, current_board_min, GameState.daily_streak]
		next_button.text = "Menu Utama"
		select_level_button.text = "Menu Utama"
		win_panel.visible = true
		return
	var best: int = MIN_MOVES[current_level]
	var stars := 3 if moves <= best else (2 if moves <= best + 5 else 1)
	if mode == "hard":
		saved_hard_stars[current_level] = maxi(saved_hard_stars[current_level], stars)
		if saved_hard_best[current_level] == 0 or moves < saved_hard_best[current_level]:
			saved_hard_best[current_level] = moves
	else:
		saved_stars[current_level] = maxi(saved_stars[current_level], stars)
		if saved_best[current_level] == 0 or moves < saved_best[current_level]:
			saved_best[current_level] = moves
		if current_level + 1 < LEVELS.size():
			unlocked = maxi(unlocked, current_level + 2)
	_save_progress()
	stars_label.text = "★".repeat(stars) + "☆".repeat(3 - stars)
	sound.play("win")
	GameState.vibrate(120)
	if current_level + 1 >= LEVELS.size():
		win_label.text = "Semua Level Selesai!"
		win_info_label.text = "Langkah: %d • Minimal: %d" % [moves, best]
		next_button.text = "Main Lagi dari Level 1"
	else:
		win_label.text = "Level Selesai!" if mode == "classic" else "Level Sulit Selesai!"
		win_info_label.text = "Langkah: %d • Minimal: %d" % [moves, best]
		next_button.text = "Level Berikutnya"
	select_level_button.text = "Pilih Level"
	win_panel.visible = true


# ----------------------------------------------------------------------- hint
func _state_key(balls_state: Array) -> String:
	var parts: PackedStringArray = []
	for t in balls_state:
		var s := ""
		for v in t:
			s += str(v)
		parts.append(s)
	return ",".join(parts)


func _valid_pours(balls_state: Array) -> Array:
	var out: Array = []
	for i in range(balls_state.size()):
		var src: Array = balls_state[i]
		if src.is_empty():
			continue
		var top: int = src[src.size() - 1]
		var run := 0
		for k in range(src.size() - 1, -1, -1):
			if src[k] == top:
				run += 1
			else:
				break
		for j in range(balls_state.size()):
			if i == j:
				continue
			var dst: Array = balls_state[j]
			if dst.size() >= Tube.CAPACITY:
				continue
			if not dst.is_empty() and dst[dst.size() - 1] != top:
				continue
			out.append([i, j, mini(run, Tube.CAPACITY - dst.size())])
	return out


func _apply_pour(balls_state: Array, pour: Array) -> Array:
	var out: Array = []
	for t in balls_state:
		out.append((t as Array).duplicate())
	var src: Array = out[pour[0]]
	var dst: Array = out[pour[1]]
	var top: int = src[src.size() - 1]
	for k in range(pour[2]):
		src.pop_back()
	for k in range(pour[2]):
		dst.append(top)
	return out


func _is_win_state(balls_state: Array) -> bool:
	for t in balls_state:
		if t.is_empty():
			continue
		if t.size() != Tube.CAPACITY:
			return false
		for v in t:
			if v != t[0]:
				return false
	return true


func _solve_first_move(balls_state: Array) -> Array:
	## BFS dari state sekarang; kembalikan [from, to] langkah pertama
	## dari solusi optimal, atau [] kalau tidak ada / batas state tercapai.
	var start_key := _state_key(balls_state)
	if _is_win_state(balls_state):
		return []
	var queue: Array = [balls_state]
	var head := 0
	var parent: Dictionary = {start_key: null}
	var parent_move: Dictionary = {}
	var visited := 1
	while head < queue.size():
		var s: Array = queue[head]
		head += 1
		for pour in _valid_pours(s):
			var ns := _apply_pour(s, pour)
			var ns_key := _state_key(ns)
			if parent.has(ns_key):
				continue
			parent[ns_key] = _state_key(s)
			parent_move[ns_key] = [pour[0], pour[1]]
			visited += 1
			if visited > HINT_STATE_CAP:
				return []
			if _is_win_state(ns):
				var k := ns_key
				var first: Array = parent_move[k]
				while parent[k] != start_key:
					k = parent[k]
					first = parent_move[k]
				return first
			queue.append(ns)
	return []


func _on_hint_pressed() -> void:
	if win_panel.visible or fail_panel.visible or pause_panel.visible or level_select_panel.visible or animating:
		return
	sound.play("click")
	_show_message("Mencari petunjuk…")
	var move := _solve_first_move(_current_balls())
	if move.is_empty():
		var pours := _valid_pours(_current_balls())
		if pours.is_empty():
			message_label.text = "Buntu! Tidak ada langkah valid — urungkan atau ulangi level."
			deadlocked = true
		else:
			_suggest_move(pours[0][0], pours[0][1], true)
		return
	_suggest_move(move[0], move[1], false)


func _suggest_move(from_i: int, to_i: int, approx: bool) -> void:
	_deselect()
	selected_index = from_i
	tubes[from_i].set_selected(true)
	var label := "Petunjuk: tuang tabung %d ke tabung %d" % [from_i + 1, to_i + 1]
	if approx:
		label += " (langkah valid)"
	_show_message(label)


# ------------------------------------------------------------------- deadlock
func _check_deadlock() -> void:
	if _check_win():
		return
	if _valid_pours(_current_balls()).is_empty():
		deadlocked = true
		message_label.text = "Buntu! Tidak ada langkah valid — urungkan atau ulangi level."
	elif deadlocked:
		deadlocked = false
		message_label.text = ""


# --------------------------------------------------------------------- polish
func _pop(tube: Tube) -> void:
	tube.pivot_offset = tube.size * 0.5
	var tw := tube.create_tween()
	tw.tween_property(tube, "scale", Vector2(1.07, 1.07), 0.09)
	tw.tween_property(tube, "scale", Vector2.ONE, 0.12)


func _shake(tube: Tube) -> void:
	var tw := tube.create_tween()
	tw.tween_property(tube, "position:x", tube.base_x + 8.0, 0.05)
	tw.tween_property(tube, "position:x", tube.base_x - 8.0, 0.05)
	tw.tween_property(tube, "position:x", tube.base_x, 0.05)


func _update_labels() -> void:
	if mode == "timed":
		level_label.text = "Skor %d" % timed_score
		var secs := int(time_left)
		moves_label.text = "Waktu %d:%02d" % [secs / 60, secs % 60]
	elif mode == "daily":
		level_label.text = "HARIAN"
		moves_label.text = "Langkah %d" % moves
	elif mode == "hard":
		level_label.text = "LEVEL %d" % (current_level + 1)
		moves_label.text = "Sisa %d" % maxi(0, move_limit - moves)
	else:
		level_label.text = "LEVEL %d" % (current_level + 1)
		moves_label.text = "Langkah %d" % moves
	undo_button.text = "↩ Urung (%d)" % undo_stack.size() if not undo_stack.is_empty() else "↩ Urung"
	add_tube_button.text = "＋ Tabung (%d)" % extra_tubes_left
	add_tube_button.disabled = extra_tubes_left <= 0


func _show_message(text: String) -> void:
	message_label.text = text
	await get_tree().create_timer(1.5).timeout
	if message_label.text == text:
		message_label.text = ""
