extends Control
class_name Tube
## Satu tabung Ball Sort: gambar tabung + bola-bola di dalamnya.
## balls: Array[int] warna, indeks 0 = paling bawah, terakhir = paling atas.
## Tap (sentuh/mouse) -> signal tapped.

signal tapped(tube: Control)

const CAPACITY: int = 4
const COLORS: Array[Color] = [
	Color(0.95, 0.30, 0.30),
	Color(0.30, 0.80, 0.40),
	Color(0.30, 0.55, 0.95),
	Color(0.98, 0.80, 0.25),
	Color(0.65, 0.45, 0.90),
]

var balls: Array[int] = []
var selected: bool = false


func _ready() -> void:
	custom_minimum_size = Vector2(96, 360)
	mouse_filter = Control.MOUSE_FILTER_STOP


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
	queue_redraw()


func set_selected(value: bool) -> void:
	selected = value
	queue_redraw()


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
	# Kaca tabung
	draw_rect(Rect2(4, 20, w - 8, h - 24), Color(1, 1, 1, 0.07), true)
	# Dinding tabung (atas terbuka)
	var border := Color(1, 1, 1, 0.55) if not selected else Color(1, 0.85, 0.2, 1)
	draw_line(Vector2(4, 20), Vector2(4, h - 4), border, 4.0)
	draw_line(Vector2(w - 4, 20), Vector2(w - 4, h - 4), border, 4.0)
	draw_line(Vector2(4, h - 4), Vector2(w - 4, h - 4), border, 4.0)
	if selected:
		# Panah penanda tabung terpilih
		var cx := w * 0.5
		draw_colored_polygon(PackedVector2Array([Vector2(cx - 12, 2), Vector2(cx + 12, 2), Vector2(cx, 14)]), Color(1, 0.85, 0.2, 1))
	# Bola-bola, dari bawah ke atas
	for i in range(balls.size()):
		var center := Vector2(w * 0.5, h - 16.0 - ball_r - float(i) * step)
		var color: Color = COLORS[balls[i]]
		draw_circle(center, ball_r, color)
		draw_arc(center, ball_r, 0, TAU, 32, color.darkened(0.35), 3.0)
		draw_circle(center + Vector2(-ball_r * 0.3, -ball_r * 0.3), ball_r * 0.28, Color(1, 1, 1, 0.35))
