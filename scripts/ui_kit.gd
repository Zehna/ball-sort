class_name UiKit
extends RefCounted
## Helper gaya UI bersama agar semua layar (loading, menu, mode,
## pengaturan, cara main) konsisten dengan layar game.

const BLUE := Color(0.23, 0.51, 0.96, 1)
const GREEN := Color(0.16, 0.65, 0.35, 1)
const SLATE := Color(0.2, 0.23, 0.33, 1)
const GOLD := Color(0.98, 0.78, 0.15, 1)
const DARK := Color(0.1, 0.11, 0.26, 1)
const GOLD_TEXT := Color(1, 0.85, 0.2, 1)
const MUTED_TEXT := Color(0.75, 0.8, 0.9, 1)


static func style(bg: Color, radius: int = 20) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = bg
	s.set_corner_radius_all(radius)
	return s


static func panel_style(bg: Color, radius: int = 24, border: Color = Color(0, 0, 0, 0), border_w: int = 0) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = bg
	s.set_corner_radius_all(radius)
	if border_w > 0:
		s.set_border_width_all(border_w)
		s.border_color = border
	return s


static func button(text: String, font_size: int, bg: Color, font_color: Color = Color(1, 1, 1, 1)) -> Button:
	var b := Button.new()
	b.text = text
	b.add_theme_font_size_override("font_size", font_size)
	b.add_theme_color_override("font_color", font_color)
	b.add_theme_stylebox_override("normal", style(bg))
	b.add_theme_stylebox_override("hover", style(bg.lightened(0.12)))
	b.add_theme_stylebox_override("pressed", style(bg.darkened(0.15)))
	b.add_theme_stylebox_override("disabled", style(Color(0.12, 0.13, 0.2, 1)))
	b.add_theme_color_override("font_disabled_color", Color(1, 1, 1, 0.35))
	return b


static func label(text: String, font_size: int, color: Color, align: HorizontalAlignment = HORIZONTAL_ALIGNMENT_CENTER) -> Label:
	var l := Label.new()
	l.text = text
	l.add_theme_font_size_override("font_size", font_size)
	l.add_theme_color_override("font_color", color)
	l.horizontal_alignment = align
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	return l


static func spacer(height: int) -> Control:
	var c := Control.new()
	c.custom_minimum_size = Vector2(0, height)
	return c


## Baris 3 tabung hias (pakai Tube asli, tidak bisa di-tap).
static func deco_tubes() -> HBoxContainer:
	var row := HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 18)
	var defs: Array = [[0, 1, 2], [3, 4, 1], [2, 0, 4]]
	for def in defs:
		var tube := Tube.new()
		row.add_child(tube)
		tube.custom_minimum_size = Vector2(84, 250)
		tube.mouse_filter = Control.MOUSE_FILTER_IGNORE
		tube.set_balls(def)
	return row


## Suara klik sekali pakai untuk layar menu (tanpa node di scene).
static func click_sound(parent: Node) -> SoundSynth:
	var s := SoundSynth.new()
	s.muted = GameState.muted
	parent.add_child(s)
	return s
