extends Control
class_name Confetti
## Semburan konfeti saat menang: potongan warna-warni jatuh dari
## atas layar sambil berputar, lalu hilang sendiri. Tidak menerima
## input (mouse_filter ignore) dan tidak mengubah data game.

const GRAVITY: float = 900.0
const LIFE: float = 2.8

var _pieces: Array = []
var _t: float = 0.0


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE


func burst(count: int = 90) -> void:
	_t = 0.0
	_pieces.clear()
	var w := size.x
	if w <= 0.0:
		w = get_viewport_rect().size.x
	var palette: Array[Color] = []
	for c in Tube.COLORS:
		palette.append(c)
	palette.append(Color(1, 0.85, 0.2, 1))
	palette.append(Color(1, 1, 1, 1))
	for i in range(count):
		_pieces.append({
			"pos": Vector2(randf() * w, -20.0 - randf() * 160.0),
			"vel": Vector2(randf_range(-90.0, 90.0), randf_range(60.0, 260.0)),
			"rot": randf() * TAU,
			"rot_vel": randf_range(-6.0, 6.0),
			"size": randf_range(8.0, 16.0),
			"color": palette[randi() % palette.size()],
		})
	visible = true
	queue_redraw()


func _process(delta: float) -> void:
	if _pieces.is_empty():
		return
	_t += delta
	for piece in _pieces:
		var vel: Vector2 = piece["vel"]
		vel.y += GRAVITY * delta
		piece["vel"] = vel
		var pos: Vector2 = piece["pos"]
		pos += vel * delta
		piece["pos"] = pos
		piece["rot"] = float(piece["rot"]) + float(piece["rot_vel"]) * delta
	queue_redraw()
	if _t >= LIFE:
		_pieces.clear()
		visible = false
		queue_free()


func _draw() -> void:
	for piece in _pieces:
		var s: float = piece["size"]
		var alpha := 1.0
		if _t > LIFE - 0.6:
			alpha = clampf((LIFE - _t) / 0.6, 0.0, 1.0)
		var color: Color = piece["color"]
		color.a = alpha
		draw_set_transform(piece["pos"], piece["rot"], Vector2.ONE)
		draw_rect(Rect2(-s * 0.5, -s * 0.3, s, s * 0.6), color)
		draw_set_transform(Vector2.ZERO, 0, Vector2.ONE)
