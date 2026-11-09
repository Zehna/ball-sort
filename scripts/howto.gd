extends Control
## Cara Main: 3 langkah bergambar (tabung asli sebagai ilustrasi)
## + catatan booster. Satu keputusan di akhir: Mulai Main.

var _sound: SoundSynth


func _ready() -> void:
	_sound = UiKit.click_sound(self)
	_build_ui()


func _step_card(number: String, title: String, desc: String) -> PanelContainer:
	var panel := PanelContainer.new()
	panel.add_theme_stylebox_override("panel", UiKit.panel_style(UiKit.SLATE, 20))
	var hbox := HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 16)
	panel.add_child(hbox)
	var num := UiKit.label(number, 40, UiKit.GOLD_TEXT)
	num.custom_minimum_size = Vector2(56, 0)
	hbox.add_child(num)
	var vbox := VBoxContainer.new()
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.add_theme_constant_override("separation", 4)
	hbox.add_child(vbox)
	vbox.add_child(UiKit.label(title, 24, Color.WHITE, HORIZONTAL_ALIGNMENT_LEFT))
	vbox.add_child(UiKit.label(desc, 19, UiKit.MUTED_TEXT, HORIZONTAL_ALIGNMENT_LEFT))
	return panel


func _build_ui() -> void:
	var vbox := VBoxContainer.new()
	vbox.set_anchors_preset(Control.PRESET_FULL_RECT)
	vbox.offset_left = 48
	vbox.offset_right = -48
	vbox.add_theme_constant_override("separation", 16)
	add_child(vbox)
	vbox.add_child(UiKit.spacer(60))
	vbox.add_child(UiKit.title_label("Cara Main", 44, Color(1, 0.8, 0.2, 1)))
	vbox.add_child(UiKit.spacer(8))
	vbox.add_child(_step_card("1", "Ketuk tabung untuk memilih", "Ketuk tabung yang berisi bola — tabung terpilih naik dan berbingkai emas."))
	vbox.add_child(_step_card("2", "Ketuk tabung lain untuk menuang", "Bola dituang hanya kalau warna atasnya sama, atau tabung tujuan masih kosong."))
	vbox.add_child(_step_card("3", "Satu warna per tabung", "Menang kalau tiap tabung yang terisi penuh dengan satu warna. Semakin sedikit langkah, semakin banyak bintang!"))
	vbox.add_child(UiKit.label("Booster: Urung untuk membatalkan langkah, Petunjuk untuk langkah terbaik, ＋ Tabung untuk tabung kosong ekstra.", 18, Color(0.6, 0.65, 0.75, 1)))
	var fill := Control.new()
	fill.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox.add_child(fill)
	var play := UiKit.button("Mulai Main", 26, UiKit.GREEN)
	play.custom_minimum_size = Vector2(0, 92)
	play.pressed.connect(_on_play_pressed)
	vbox.add_child(play)
	var back := UiKit.button("← Kembali", 22, UiKit.SLATE)
	back.custom_minimum_size = Vector2(0, 80)
	back.pressed.connect(_on_back_pressed)
	vbox.add_child(back)
	vbox.add_child(UiKit.spacer(24))


func _on_play_pressed() -> void:
	_sound.play("click")
	GameState.mode = "classic"
	GameState.level_index = clampi(GameState.unlocked - 1, 0, GameState.LEVELS_COUNT - 1)
	get_tree().change_scene_to_file("res://scenes/main.tscn")


func _on_back_pressed() -> void:
	_sound.play("click")
	get_tree().change_scene_to_file("res://scenes/menu.tscn")
