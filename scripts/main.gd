extends Control
## Ball Sort Warna — kontroler game.
## Tap tabung untuk pilih, tap tabung lain untuk tuang.
## Tuang memindahkan seluruh rangkaian bola warna sama di atas
## (sebatas ruang kosong di tabung tujuan). Menang kalau tiap tabung
## yang terisi penuh dengan satu warna.

# Level: tiap tabung = Array warna (indeks 0 = paling bawah).
# Warna: 0 merah, 1 hijau, 2 biru, 3 kuning, 4 ungu.
# Ketiga level sudah dibuktikan bisa selesai (solver BFS):
# L1 min 10 langkah, L2 min 13 langkah, L3 min 16 langkah.
const LEVELS: Array = [
	[[0, 1, 0, 2], [1, 2, 1, 0], [2, 0, 2, 1], [], []],
	[[0, 1, 2, 3], [1, 2, 3, 0], [2, 3, 0, 1], [3, 0, 1, 2], [], []],
	[[0, 1, 2, 3], [1, 2, 3, 4], [2, 3, 4, 0], [3, 4, 0, 1], [4, 0, 1, 2], [], []],
]

var current_level: int = 0
var tubes: Array = []
var selected_index: int = -1
var moves: int = 0
var undo_stack: Array = []

@onready var tubes_container: Control = $TubesContainer
@onready var level_label: Label = $LevelLabel
@onready var moves_label: Label = $MovesLabel
@onready var message_label: Label = $MessageLabel
@onready var undo_button: Button = $UndoButton
@onready var restart_button: Button = $RestartButton
@onready var win_panel: PanelContainer = $WinPanel
@onready var win_label: Label = $WinPanel/VBox/WinLabel
@onready var win_info_label: Label = $WinPanel/VBox/WinInfoLabel
@onready var next_button: Button = $WinPanel/VBox/NextButton


func _ready() -> void:
	undo_button.pressed.connect(_on_undo_pressed)
	restart_button.pressed.connect(_on_restart_pressed)
	next_button.pressed.connect(_on_next_pressed)
	load_level(0)


func load_level(index: int) -> void:
	current_level = index
	for child in tubes_container.get_children():
		child.queue_free()
	tubes.clear()
	undo_stack.clear()
	selected_index = -1
	moves = 0
	win_panel.visible = false
	var def: Array = LEVELS[current_level]
	var count := def.size()
	var avail := size.x - 32.0
	var gap := 12.0
	var tube_w := minf(96.0, (avail - float(count - 1) * gap) / float(count))
	var total := float(count) * tube_w + float(count - 1) * gap
	var start_x := (size.x - total) * 0.5
	for i in range(count):
		var tube := Tube.new()
		tube.position = Vector2(start_x + float(i) * (tube_w + gap), 20)
		tube.size = Vector2(tube_w, 360)
		tube.set_balls(def[i])
		tube.tapped.connect(_on_tube_tapped)
		tubes_container.add_child(tube)
		tubes.append(tube)
	_update_labels()


func _on_tube_tapped(tube) -> void:
	if win_panel.visible:
		return
	var index := tubes.find(tube)
	if index == -1:
		return
	if selected_index == -1:
		if tube.is_empty():
			return
		selected_index = index
		tube.set_selected(true)
		return
	if index == selected_index:
		tube.set_selected(false)
		selected_index = -1
		return
	_try_pour(selected_index, index)


func _try_pour(from_index: int, to_index: int) -> void:
	var src = tubes[from_index]
	var dst = tubes[to_index]
	var from_color: int = src.top_color()
	if dst.is_full():
		_show_message("Tabung tujuan sudah penuh!")
		_deselect()
		return
	if not dst.is_empty() and dst.top_color() != from_color:
		_show_message("Warna atas tidak cocok!")
		_deselect()
		return
	undo_stack.append(_snapshot())
	var space: int = Tube.CAPACITY - dst.balls.size()
	var n: int = mini(src.top_run(), space)
	var moving: Array[int] = []
	for k in range(n):
		moving.append(src.balls.pop_back())
	moving.reverse()
	for v in moving:
		dst.balls.append(v)
	moves += 1
	_deselect()
	src.queue_redraw()
	dst.queue_redraw()
	_update_labels()
	if _check_win():
		_show_win()


func _snapshot() -> Dictionary:
	var balls_copy: Array = []
	for t in tubes:
		balls_copy.append(t.balls.duplicate())
	return {"balls": balls_copy, "moves": moves}


func _restore(snapshot: Dictionary) -> void:
	var balls_copy: Array = snapshot["balls"]
	for i in range(tubes.size()):
		tubes[i].set_balls(balls_copy[i])
	moves = int(snapshot["moves"])
	_update_labels()


func _on_undo_pressed() -> void:
	if undo_stack.is_empty():
		_show_message("Tidak ada langkah untuk diurungkan.")
		return
	_deselect()
	_restore(undo_stack.pop_back())
	_show_message("Langkah diurungkan.")


func _on_restart_pressed() -> void:
	load_level(current_level)
	_show_message("Level diulang dari awal.")


func _on_next_pressed() -> void:
	if current_level + 1 >= LEVELS.size():
		load_level(0)
	else:
		load_level(current_level + 1)


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
	if current_level + 1 >= LEVELS.size():
		win_label.text = "Semua Level Selesai!"
		win_info_label.text = "Kamu menyelesaikan 3 level."
		next_button.text = "Main Lagi dari Level 1"
	else:
		win_label.text = "Level Selesai!"
		win_info_label.text = "Selesai dalam %d langkah." % moves
		next_button.text = "Level Berikutnya"
	win_panel.visible = true


func _update_labels() -> void:
	level_label.text = "Level %d/%d" % [current_level + 1, LEVELS.size()]
	moves_label.text = "Langkah: %d" % moves


func _show_message(text: String) -> void:
	message_label.text = text
	await get_tree().create_timer(1.5).timeout
	if message_label.text == text:
		message_label.text = ""
