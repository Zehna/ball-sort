extends Control
## Pilih Mode: 4 kartu — Klasik, Waktu, Sulit, Harian — masing-masing
## dengan deskripsi + rekor terbaik. Klasik/Sulit → pilih level,
## Waktu/Harian → langsung main.

var _sound: SoundSynth


func _ready() -> void:
	_sound = UiKit.click_sound(self)
	_build_ui()


func _mode_card(title: String, desc: String, record: String, bg: Color, font_color: Color = Color(1, 1, 1, 1)) -> Button:
	var b := UiKit.button("%s\n%s\n%s" % [title, desc, record], 22, bg, font_color)
	b.custom_minimum_size = Vector2(0, 118)
	return b


func _build_ui() -> void:
	var bg := ColorRect.new()
	bg.color = Color(0.07, 0.08, 0.2, 1)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)
	var vbox := VBoxContainer.new()
	vbox.set_anchors_preset(Control.PRESET_FULL_RECT)
	vbox.offset_left = 48
	vbox.offset_right = -48
	vbox.add_theme_constant_override("separation", 16)
	add_child(vbox)
	vbox.add_child(UiKit.spacer(60))
	vbox.add_child(UiKit.label("Pilih Mode", 44, Color.WHITE))
	vbox.add_child(UiKit.label("Empat cara main, satu tujuan: satu warna per tabung", 19, UiKit.MUTED_TEXT))
	vbox.add_child(UiKit.spacer(16))
	var classic := _mode_card("KLASIK", "30 level, santai, tanpa batas waktu", "Bintang: %d/90" % GameState.total_stars(), UiKit.GREEN)
	classic.pressed.connect(_on_classic_pressed)
	vbox.add_child(classic)
	var timed := _mode_card("WAKTU", "90 detik per papan — selesaikan sebanyak mungkin", "Skor terbaik: %d" % GameState.timed_best_score, UiKit.BLUE)
	timed.pressed.connect(_on_timed_pressed)
	vbox.add_child(timed)
	var hard := _mode_card("SULIT", "Langkah terbatas — pikirkan tiap tuangan", "Bintang: %d/90" % GameState.total_hard_stars(), UiKit.SLATE)
	hard.pressed.connect(_on_hard_pressed)
	vbox.add_child(hard)
	var daily := _mode_card("HARIAN", "Satu puzzle baru setiap hari — jaga streak", "Streak: %d hari" % GameState.daily_streak, UiKit.GOLD, Color(0.12, 0.09, 0, 1))
	daily.pressed.connect(_on_daily_pressed)
	vbox.add_child(daily)
	var fill := Control.new()
	fill.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox.add_child(fill)
	var back := UiKit.button("← Kembali", 22, UiKit.SLATE)
	back.custom_minimum_size = Vector2(0, 80)
	back.pressed.connect(_on_back_pressed)
	vbox.add_child(back)
	vbox.add_child(UiKit.spacer(24))


func _click() -> void:
	_sound.play("click")


func _on_classic_pressed() -> void:
	_click()
	GameState.mode = "classic"
	get_tree().change_scene_to_file("res://scenes/main.tscn")


func _on_timed_pressed() -> void:
	_click()
	GameState.mode = "timed"
	get_tree().change_scene_to_file("res://scenes/main.tscn")


func _on_hard_pressed() -> void:
	_click()
	GameState.mode = "hard"
	get_tree().change_scene_to_file("res://scenes/main.tscn")


func _on_daily_pressed() -> void:
	_click()
	GameState.mode = "daily"
	get_tree().change_scene_to_file("res://scenes/main.tscn")


func _on_back_pressed() -> void:
	_click()
	get_tree().change_scene_to_file("res://scenes/menu.tscn")
