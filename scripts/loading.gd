extends Control
## Layar loading: splash + progress nyata + tips bergilir.
## Langkahnya kerja beneran (muat save, preload scene), bukan bar palsu.
## Total ~1,6 detik agar splash sempat terbaca, lalu ke menu utama.

const TIPS: Array[String] = [
	"Ketuk tabung untuk memilih, ketuk tabung lain untuk menuang.",
	"Hanya warna atas yang sama yang bisa dituang ke satu tabung.",
	"Tabung yang sudah satu warna penuh akan berkilau emas.",
	"Stuck? Pakai Petunjuk — solver akan menunjukkan langkah terbaik.",
	"Mode Harian: satu puzzle baru setiap hari, jaga streak-mu!",
]

var _bar: ProgressBar
var _status: Label
var _tip: Label


func _ready() -> void:
	_build_ui()
	_run_loading()


func _build_ui() -> void:
	var vbox := VBoxContainer.new()
	vbox.set_anchors_preset(Control.PRESET_FULL_RECT)
	vbox.offset_left = 48
	vbox.offset_right = -48
	vbox.add_theme_constant_override("separation", 18)
	add_child(vbox)
	vbox.add_child(UiKit.spacer(60))
	var icon := TextureRect.new()
	icon.texture = load("res://icon.svg")
	icon.custom_minimum_size = Vector2(128, 128)
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	vbox.add_child(icon)
	vbox.add_child(UiKit.spacer(8))
	var title := UiKit.title_label("BALL SORT", 64, Color(1, 0.8, 0.2, 1))
	vbox.add_child(title)
	var subtitle := UiKit.title_label("WARNA", 34, UiKit.GOLD_TEXT)
	vbox.add_child(subtitle)
	vbox.add_child(UiKit.spacer(20))
	vbox.add_child(UiKit.deco_tubes())
	vbox.add_child(UiKit.spacer(60))
	_bar = ProgressBar.new()
	_bar.min_value = 0
	_bar.max_value = 100
	_bar.value = 0
	_bar.show_percentage = false
	_bar.custom_minimum_size = Vector2(0, 18)
	_bar.add_theme_stylebox_override("background", UiKit.style(Color(0.2, 0.23, 0.33, 1), 9))
	_bar.add_theme_stylebox_override("fill", UiKit.style(UiKit.GOLD, 9))
	vbox.add_child(_bar)
	_status = UiKit.label("Memuat…", 20, UiKit.MUTED_TEXT)
	vbox.add_child(_status)
	_tip = UiKit.label(TIPS[0], 18, Color(0.6, 0.65, 0.75, 1))
	vbox.add_child(_tip)


func _set_progress(value: float, status: String, tip_index: int) -> void:
	_bar.value = value
	_status.text = status
	_tip.text = TIPS[tip_index % TIPS.size()]


func _run_loading() -> void:
	_set_progress(10, "Memuat progres…", 0)
	GameState.load_all()
	await get_tree().create_timer(0.35).timeout
	_set_progress(40, "Menyiapkan level…", 1)
	ResourceLoader.load("res://scenes/menu.tscn")
	ResourceLoader.load("res://scenes/mode_select.tscn")
	ResourceLoader.load("res://scenes/settings.tscn")
	ResourceLoader.load("res://scenes/howto.tscn")
	await get_tree().create_timer(0.35).timeout
	_set_progress(70, "Menyiapkan permainan…", 2)
	ResourceLoader.load("res://scenes/main.tscn")
	await get_tree().create_timer(0.35).timeout
	_set_progress(90, "Menyiapkan suara…", 3)
	var s := SoundSynth.new()
	s.muted = GameState.muted
	add_child(s)
	s.play("click")
	await get_tree().create_timer(0.35).timeout
	_set_progress(100, "Siap!", 4)
	await get_tree().create_timer(0.25).timeout
	get_tree().change_scene_to_file("res://scenes/menu.tscn")
