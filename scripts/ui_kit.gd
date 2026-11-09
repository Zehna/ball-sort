class_name UiKit
extends RefCounted
## Helper gaya UI bersama agar semua layar (loading, menu, mode,
## pengaturan, cara main) konsisten dengan layar game.

const BLUE := Color(0.20, 0.60, 0.86, 1)
const GREEN := Color(0.18, 0.80, 0.44, 1)
const SLATE := Color(0.2, 0.23, 0.33, 1)
const GOLD := Color(0.95, 0.61, 0.07, 1)
const RED := Color(0.91, 0.29, 0.24, 1)
const DARK := Color(0.078, 0.09, 0.169, 1)
const GOLD_TEXT := Color(1, 0.85, 0.2, 1)
const MUTED_TEXT := Color(0.75, 0.8, 0.9, 1)

## Aset UI (SVG di res://assets/ui/) — bintang + gembok dari board referensi.
const STAR_GOLD: Texture2D = preload("res://assets/ui/star_gold.svg")
const STAR_EMPTY: Texture2D = preload("res://assets/ui/star_empty.svg")
const LOCK: Texture2D = preload("res://assets/ui/lock.svg")


static func style(bg: Color, radius: int = 20) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = bg
	s.set_corner_radius_all(radius)
	return s


## Tombol pill 3D: bayangan bawah memberi kesan timbul; saat
## ditekan bayangannya mengecil (tombol "tenggelam").
static func style_3d(bg: Color, radius: int = 20, depth: int = 4) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = bg
	s.set_corner_radius_all(radius)
	s.shadow_color = Color(0, 0, 0, 0.35)
	s.shadow_size = depth
	s.shadow_offset = Vector2(0, depth)
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
	b.add_theme_stylebox_override("normal", style_3d(bg, 20, 4))
	b.add_theme_stylebox_override("hover", style_3d(bg.lightened(0.12), 20, 4))
	b.add_theme_stylebox_override("pressed", style_3d(bg.darkened(0.15), 20, 1))
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


## Judul gaya kartun kasual: outline putih tebal + bayangan jatuh.
static func title_label(text: String, font_size: int, color: Color) -> Label:
	var l := label(text, font_size, color)
	l.add_theme_color_override("font_outline_color", Color(1, 1, 1, 1))
	l.add_theme_constant_override("outline_size", maxi(6, font_size / 5))
	l.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.5))
	l.add_theme_constant_override("shadow_offset_x", 0)
	l.add_theme_constant_override("shadow_offset_y", maxi(2, font_size / 12))
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
	s.sfx_volume = GameState.sfx_volume
	parent.add_child(s)
	return s
