extends Control
class_name Tube
## Satu tabung Ball Sort: gambar tabung kaca + bola-bola di dalamnya.
## balls: Array[int] warna, indeks 0 = paling bawah, terakhir = paling atas.
## Tap (sentuh/mouse) -> signal tapped.
## Tabung terpilih naik sedikit + border emas; tabung selesai berkilau emas.

signal tapped(tube: Control)

const CAPACITY: int = 4
const COLORS: Array[Color] = [
	Color(1.00, 0.23, 0.19), # merah #FF3B30
	Color(0.20, 0.78, 0.35), # hijau #34C759
	Color(0.00, 0.48, 1.00), # biru #007AFF
	Color(1.00, 0.80, 0.00), # kuning #FFCC00
	Color(0.69, 0.32, 0.87), # ungu #AF52DE
	Color(1.00, 0.58, 0.00), # oranye #FF9500
	Color(0.19, 0.84, 0.78), # tosca #30D5C8
]


## Aset gambar (SVG di res://assets/) — tampilan sama persis dengan board
## referensi: bola glossy 3D, tabung kaca, panah penunjuk, bintang emas.
const BALL_TEXTURES: Array[Texture2D] = [
	preload("res://assets/balls/ball_red.svg"),
	preload("res://assets/balls/ball_green.svg"),
	preload("res://assets/balls/ball_blue.svg"),
	preload("res://assets/balls/ball_yellow.svg"),
	preload("res://assets/balls/ball_purple.svg"),
	preload("res://assets/balls/ball_orange.svg"),
	preload("res://assets/balls/ball_teal.svg"),
]
const TUBE_TEXTURE: Texture2D = preload("res://assets/tubes/tube_glass.svg")
const ARROW_TEXTURE: Texture2D = preload("res://assets/ui/arrow_down.svg")
const STAR_GOLD: Texture2D = preload("res://assets/ui/star_gold.svg")

var balls: Array[int] = []
var hidden_top: int = 0
var selected: bool = false
var base_x: float = 0.0
var base_y: float = 0.0
var tube_style: StyleBoxFlat


func _ready() -> void:
	custom_minimum_size = Vector2(96, 360)
	mouse_filter = Control.MOUSE_FILTER_STOP
	base_x = position.x
	base_y = position.y
	tube_style = StyleBoxFlat.new()
	tube_style.bg_color = Color(1, 1, 1, 0.05)
	tube_style.set_corner_radius_all(16)
	tube_style.set_border_width_all(3)
	tube_style.border_color = Color(1, 1, 1, 0.55)


func _gui_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch and event.pressed:
		tapped.emit(self)
		accept_event()
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		tapped.emit(self)
		accept_event()


func set_balls(arr: Array) -> void:
	balls.clear()
	for v in arr:
		balls.append(int(v))
	hidden_top = 0
	_refresh_border()
	queue_redraw()


## Sembunyikan N bola teratas saat sedang diterbangkan oleh PourFx.
## Data balls tidak berubah — hanya gambar yang disembunyikan.
func set_hidden_top(n: int) -> void:
	hidden_top = n
	queue_redraw()


func set_selected(value: bool) -> void:
	selected = value
	position.y = base_y - 18.0 if selected else base_y
	_refresh_border()
	queue_redraw()


func _refresh_border() -> void:
	if tube_style == null:
		return
	if selected or is_complete():
		tube_style.border_color = Color(1, 0.85, 0.2, 1)
	else:
		tube_style.border_color = Color(1, 1, 1, 0.5)


func is_empty() -> bool:
	return balls.is_empty()


func is_full() -> bool:
	return balls.size() >= CAPACITY


func top_color() -> int:
	if balls.is_empty():
		return -1
	return balls[balls.size() - 1]


func top_run() -> int:
	if balls.is_empty():
		return 0
	var color := balls[balls.size() - 1]
	var run := 0
	for i in range(balls.size() - 1, -1, -1):
		if balls[i] == color:
			run += 1
		else:
			break
	return run


func is_complete() -> bool:
	if balls.size() != CAPACITY:
		return false
	for v in balls:
		if v != balls[0]:
			return false
	return true


func _draw() -> void:
	var w := size.x
	var h := size.y
	var ball_r := (w * 0.5) - 8.0
	var step := ball_r * 2.0 + 6.0
	# Bayangan tabung di lantai (elips pipih)
	draw_set_transform(Vector2(w * 0.5, h - 6), 0, Vector2(1.0, 0.22))
	draw_circle(Vector2.ZERO, w * 0.36, Color(0, 0, 0, 0.35))
	draw_set_transform(Vector2.ZERO, 0, Vector2.ONE)
	# Tabung kaca (tekstur SVG) + border (emas saat terpilih/selesai)
	draw_texture_rect(TUBE_TEXTURE, Rect2(4, 20, w - 8, h - 24), false)
	draw_style_box(tube_style, Rect2(4, 20, w - 8, h - 24))
	if selected:
		# Panah penunjuk emas di atas tabung terpilih (seperti di board)
		draw_texture_rect(ARROW_TEXTURE, Rect2(w * 0.5 - 14, -10, 28, 38), false)
	if is_complete() and not balls.is_empty():
		# Bintang emas di atas tabung yang selesai
		draw_texture_rect(STAR_GOLD, Rect2(w * 0.5 - 30, -2, 18, 18), false)
		draw_texture_rect(STAR_GOLD, Rect2(w * 0.5 + 12, -6, 14, 14), false)
	# Bola-bola (tekstur SVG), dari bawah ke atas (lewati yang sedang diterbangkan)
	for i in range(balls.size() - hidden_top):
		var center := Vector2(w * 0.5, h - 16.0 - ball_r - float(i) * step)
		var tex: Texture2D = BALL_TEXTURES[balls[i]]
		draw_texture_rect(tex, Rect2(center - Vector2(ball_r, ball_r), Vector2(ball_r * 2.0, ball_r * 2.0)), false)
