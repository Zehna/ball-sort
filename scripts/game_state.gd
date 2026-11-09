extends Node
## GameState — autoload, pemilik tunggal data save + pilihan mode.
## Save: user://ball_sort_save.cfg. Nama section/key lama dipertahankan
## agar progres pemain dari versi sebelumnya tidak hilang.
## Mode: "classic" | "timed" | "hard" | "daily".

const SAVE_PATH := "user://ball_sort_save.cfg"
const LEVELS_COUNT := 30

# Pilihan saat ini — diisi layar menu/mode sebelum pindah scene.
var mode: String = "classic"
var level_index: int = 0

# Progres klasik
var unlocked: int = 1
var stars: Array[int] = []
var best: Array[int] = []
# Progres mode sulit (per level, panjang sama dengan klasik)
var hard_stars: Array[int] = []
var hard_best: Array[int] = []
# Harian
var daily_last_date: String = ""
var daily_streak: int = 0
# Mode waktu
var timed_best_score: int = 0
# Pengaturan
var muted: bool = false
var vibrate_enabled: bool = true


func _ready() -> void:
	load_all()


func today_string() -> String:
	var d := Time.get_date_dict_from_system()
	return "%04d-%02d-%02d" % [d["year"], d["month"], d["day"]]


func daily_seed_for_today() -> int:
	var d := Time.get_date_dict_from_system()
	return int(d["year"]) * 10000 + int(d["month"]) * 100 + int(d["day"])


func is_daily_done_today() -> bool:
	return daily_last_date == today_string()


func load_all() -> void:
	stars.resize(LEVELS_COUNT)
	stars.fill(0)
	best.resize(LEVELS_COUNT)
	best.fill(0)
	hard_stars.resize(LEVELS_COUNT)
	hard_stars.fill(0)
	hard_best.resize(LEVELS_COUNT)
	hard_best.fill(0)
	unlocked = 1
	daily_last_date = ""
	daily_streak = 0
	timed_best_score = 0
	muted = false
	vibrate_enabled = true
	var cfg := ConfigFile.new()
	if cfg.load(SAVE_PATH) != OK:
		return
	unlocked = clampi(int(cfg.get_value("progress", "unlocked", 1)), 1, LEVELS_COUNT)
	_load_int_array(cfg, "progress", "stars", stars)
	_load_int_array(cfg, "progress", "best", best)
	_load_int_array(cfg, "progress", "hard_stars", hard_stars)
	_load_int_array(cfg, "progress", "hard_best", hard_best)
	daily_last_date = str(cfg.get_value("daily", "last_date", ""))
	daily_streak = maxi(0, int(cfg.get_value("daily", "streak", 0)))
	timed_best_score = maxi(0, int(cfg.get_value("timed", "best_score", 0)))
	muted = bool(cfg.get_value("settings", "muted", false))
	vibrate_enabled = bool(cfg.get_value("settings", "vibrate", true))


func _load_int_array(cfg: ConfigFile, section: String, key: String, target: Array[int]) -> void:
	var arr: Array = cfg.get_value(section, key, [])
	for i in range(mini(arr.size(), target.size())):
		target[i] = maxi(0, int(arr[i]))


func save_all() -> void:
	var cfg := ConfigFile.new()
	cfg.set_value("progress", "unlocked", unlocked)
	cfg.set_value("progress", "stars", stars)
	cfg.set_value("progress", "best", best)
	cfg.set_value("progress", "hard_stars", hard_stars)
	cfg.set_value("progress", "hard_best", hard_best)
	cfg.set_value("daily", "last_date", daily_last_date)
	cfg.set_value("daily", "streak", daily_streak)
	cfg.set_value("timed", "best_score", timed_best_score)
	cfg.set_value("settings", "muted", muted)
	cfg.set_value("settings", "vibrate", vibrate_enabled)
	cfg.save(SAVE_PATH)


func total_stars() -> int:
	var t := 0
	for v in stars:
		t += v
	return t


func total_hard_stars() -> int:
	var t := 0
	for v in hard_stars:
		t += v
	return t


func vibrate(ms: int) -> void:
	if vibrate_enabled:
		Input.vibrate_handheld(ms)


func record_timed_score(score: int) -> void:
	if score > timed_best_score:
		timed_best_score = score
		save_all()


func record_daily_win() -> void:
	var today := today_string()
	if daily_last_date == today:
		return
	var gap := _date_to_days(today) - _date_to_days(daily_last_date)
	if gap == 1:
		daily_streak += 1
	else:
		daily_streak = 1
	daily_last_date = today
	save_all()


func _date_to_days(date_str: String) -> int:
	var parts := date_str.split("-")
	if parts.size() != 3:
		return -1
	var dict := {
		"year": int(parts[0]), "month": int(parts[1]), "day": int(parts[2]),
		"hour": 0, "minute": 0, "second": 0,
	}
	return int(Time.get_unix_time_from_datetime_dict(dict) / 86400)


func reset_progress() -> void:
	stars.fill(0)
	best.fill(0)
	hard_stars.fill(0)
	hard_best.fill(0)
	unlocked = 1
	daily_last_date = ""
	daily_streak = 0
	timed_best_score = 0
	save_all()
