extends Control
## Pengaturan: suara, getar, reset progres (dengan konfirmasi).
## Perubahan langsung tersimpan lewat GameState.

var _sound: SoundSynth
var _sound_button: Button
var _music_button: Button
var _vibrate_button: Button
var _confirm_panel: PanelContainer


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
	vbox.add_child(UiKit.spacer(60))
	vbox.add_child(UiKit.title_label("Pengaturan", 44, Color(1, 0.8, 0.2, 1)))
	vbox.add_child(UiKit.spacer(16))
	_sound_button = UiKit.button("", 24, UiKit.SLATE)
	_sound_button.custom_minimum_size = Vector2(0, 88)
	_sound_button.pressed.connect(_on_sound_pressed)
	vbox.add_child(_sound_button)
	_music_button = UiKit.button("", 24, UiKit.SLATE)
	_music_button.custom_minimum_size = Vector2(0, 88)
	_music_button.pressed.connect(_on_music_pressed)
	vbox.add_child(_music_button)
	_vibrate_button = UiKit.button("", 24, UiKit.SLATE)
	_vibrate_button.custom_minimum_size = Vector2(0, 88)
	_vibrate_button.pressed.connect(_on_vibrate_pressed)
	vbox.add_child(_vibrate_button)
	var reset := UiKit.button("Reset Progres", 24, Color(0.75, 0.25, 0.25, 1))
	reset.custom_minimum_size = Vector2(0, 88)
	reset.pressed.connect(_on_reset_pressed)
	vbox.add_child(reset)
	var fill := Control.new()
	fill.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox.add_child(fill)
	vbox.add_child(UiKit.label("Ball Sort Warna — v1.3.0 (Fase 4)", 18, Color(0.6, 0.65, 0.75, 1)))
	var back := UiKit.button("← Kembali", 22, UiKit.SLATE)
	back.custom_minimum_size = Vector2(0, 80)
	back.pressed.connect(_on_back_pressed)
	vbox.add_child(back)
	vbox.add_child(UiKit.spacer(24))
	_refresh_buttons()
	# Panel konfirmasi reset (overlay, awalnya sembunyi)
	_confirm_panel = PanelContainer.new()
	_confirm_panel.visible = false
	_confirm_panel.set_anchors_preset(Control.PRESET_CENTER)
	_confirm_panel.offset_left = -240
	_confirm_panel.offset_top = -140
	_confirm_panel.offset_right = 240
	_confirm_panel.offset_bottom = 140
	_confirm_panel.add_theme_stylebox_override("panel", UiKit.panel_style(UiKit.DARK, 28, UiKit.GOLD, 3))
	add_child(_confirm_panel)
	var cvbox := VBoxContainer.new()
	cvbox.add_theme_constant_override("separation", 14)
	_confirm_panel.add_child(cvbox)
	cvbox.add_child(UiKit.label("Hapus semua progres?", 26, Color.WHITE))
	cvbox.add_child(UiKit.label("Level, bintang, dan streak harian akan hilang.", 19, UiKit.MUTED_TEXT))
	var yes := UiKit.button("Ya, Hapus", 22, Color(0.75, 0.25, 0.25, 1))
	yes.pressed.connect(_on_reset_confirmed)
	cvbox.add_child(yes)
	var no := UiKit.button("Batal", 22, UiKit.SLATE)
	no.pressed.connect(_on_reset_cancelled)
	cvbox.add_child(no)


func _refresh_buttons() -> void:
	_sound_button.text = "Suara: Mati" if GameState.muted else "Suara: Nyala"
	_music_button.text = "Musik: Mati" if not GameState.music_enabled else "Musik: Nyala"
	_vibrate_button.text = "Getar: Mati" if not GameState.vibrate_enabled else "Getar: Nyala"


func _on_sound_pressed() -> void:
	GameState.muted = not GameState.muted
	GameState.save_all()
	_sound.muted = GameState.muted
	_refresh_buttons()
	_sound.play("click")


func _on_music_pressed() -> void:
	GameState.set_music_enabled(not GameState.music_enabled)
	_refresh_buttons()
	_sound.play("click")


func _on_vibrate_pressed() -> void:
	GameState.vibrate_enabled = not GameState.vibrate_enabled
	GameState.save_all()
	_refresh_buttons()
	_sound.play("click")
	GameState.vibrate(40)


func _on_reset_pressed() -> void:
	_sound.play("click")
	_confirm_panel.visible = true


func _on_reset_confirmed() -> void:
	GameState.reset_progress()
	_confirm_panel.visible = false
	_refresh_buttons()
	_sound.play("click")


func _on_reset_cancelled() -> void:
	_sound.play("click")
	_confirm_panel.visible = false


func _on_back_pressed() -> void:
	_sound.play("click")
	get_tree().change_scene_to_file("res://scenes/menu.tscn")
