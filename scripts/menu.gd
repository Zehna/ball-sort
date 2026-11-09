extends Control
## Menu utama: judul + tombol MAIN (lanjut level terakhir) + grid
## Mode / Harian / Pengaturan / Cara Main + ringkasan progres di bawah.
## Semua tujuan ≤ 2 tap dari sini.

var _sound: SoundSynth
var _footer: Label
var _daily_button: Button


func _ready() -> void:
	_sound = UiKit.click_sound(self)
	_build_ui()


func _build_ui() -> void:
	var vbox := VBoxContainer.new()
	vbox.set_anchors_preset(Control.PRESET_FULL_RECT)
	vbox.offset_left = 48
	vbox.offset_right = -48
	vbox.add_theme_constant_override("separation", 16)
	add_child(vbox)
	vbox.add_child(UiKit.spacer(70))
	vbox.add_child(UiKit.title_label("BALL SORT", 56, Color(1, 0.8, 0.2, 1)))
	vbox.add_child(UiKit.title_label("WARNA", 30, UiKit.GOLD_TEXT))
	vbox.add_child(UiKit.label("Tuang bola sampai tiap tabung satu warna", 20, UiKit.MUTED_TEXT))
	vbox.add_child(UiKit.spacer(10))
	vbox.add_child(UiKit.deco_tubes())
	vbox.add_child(UiKit.spacer(30))
	var play := UiKit.button("MULAI MAIN", 30, UiKit.GREEN)
	play.custom_minimum_size = Vector2(0, 96)
	play.pressed.connect(_on_play_pressed)
	vbox.add_child(play)
	var row1 := HBoxContainer.new()
	row1.add_theme_constant_override("separation", 16)
	vbox.add_child(row1)
	var mode_button := UiKit.button("Mode", 24, UiKit.BLUE)
	mode_button.custom_minimum_size = Vector2(0, 88)
	mode_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	mode_button.pressed.connect(_on_mode_pressed)
	row1.add_child(mode_button)
	_daily_button = UiKit.button(_daily_text(), 24, UiKit.GOLD, Color(0.12, 0.09, 0, 1))
	_daily_button.custom_minimum_size = Vector2(0, 88)
	_daily_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_daily_button.pressed.connect(_on_daily_pressed)
	row1.add_child(_daily_button)
	var row2 := HBoxContainer.new()
	row2.add_theme_constant_override("separation", 16)
	vbox.add_child(row2)
	var settings_button := UiKit.button("Pengaturan", 24, UiKit.SLATE)
	settings_button.custom_minimum_size = Vector2(0, 88)
	settings_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	settings_button.pressed.connect(_on_settings_pressed)
	row2.add_child(settings_button)
	var howto_button := UiKit.button("Cara Main", 24, UiKit.SLATE)
	howto_button.custom_minimum_size = Vector2(0, 88)
	howto_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	howto_button.pressed.connect(_on_howto_pressed)
	row2.add_child(howto_button)
	var fill := Control.new()
	fill.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox.add_child(fill)
	_footer = UiKit.label("", 19, UiKit.MUTED_TEXT)
	vbox.add_child(_footer)
	vbox.add_child(UiKit.spacer(24))
	_update_footer()


func _daily_text() -> String:
	if GameState.is_daily_done_today():
		return "Harian\nSelesai • Streak %d" % GameState.daily_streak
	return "Harian\nStreak %d" % GameState.daily_streak


func _update_footer() -> void:
	_footer.text = "Level %d/30  •  Bintang %d/90  •  Skor Waktu: %d" % [
		GameState.unlocked, GameState.total_stars(), GameState.timed_best_score]


func _click() -> void:
	_sound.play("click")


func _on_play_pressed() -> void:
	_click()
	GameState.mode = "classic"
	GameState.level_index = clampi(GameState.unlocked - 1, 0, GameState.LEVELS_COUNT - 1)
	get_tree().change_scene_to_file("res://scenes/main.tscn")


func _on_mode_pressed() -> void:
	_click()
	get_tree().change_scene_to_file("res://scenes/mode_select.tscn")


func _on_daily_pressed() -> void:
	_click()
	GameState.mode = "daily"
	get_tree().change_scene_to_file("res://scenes/main.tscn")


func _on_settings_pressed() -> void:
	_click()
	get_tree().change_scene_to_file("res://scenes/settings.tscn")


func _on_howto_pressed() -> void:
	_click()
	get_tree().change_scene_to_file("res://scenes/howto.tscn")
