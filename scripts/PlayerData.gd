extends Node

const SAVE_FILE_PATH = "user://player_progress.json"
const GOOGLE_SHEETS_API_URL = "https://script.google.com/macros/s/AKfycbzRUlJcvnjKqHNKmLmIwXj03vQGfacKX4ZwIrItm81CzVZMVVek01Q3BNBzvOBphWQhOg/exec"

var player_name: String = ""
var is_sound_muted: bool = false

var current_materi_index: int = 1
var current_latihan_index: int = 1

# Belajar Bertahap / Gameplay Mode State
var is_gameplay_mode: bool = false
var total_stars: int = 0
var current_stage_level: int = 1
var max_unlocked_stage: int = 1
var cleared_stages: Dictionary = {} # stage_number -> true

# Latihan retry & back flow state
var from_latihan_retry: bool = false
var latihan_return_question_idx: int = 0

# Random question cycle pool for endless levels
var random_question_indices: Array[int] = []

# Background HTTP node for syncing score to Google Sheets
var _http_sync_node: HTTPRequest = null

func _ready() -> void:
	randomize()
	
	# Setup background HTTP client for automatic cloud sync
	_http_sync_node = HTTPRequest.new()
	_http_sync_node.use_threads = true
	_http_sync_node.timeout = 8.0
	add_child(_http_sync_node)
	_http_sync_node.request_completed.connect(_on_sync_completed)
	
	load_progress()
	
	if player_name.is_empty():
		player_name = _generate_default_player_name()
		save_progress()

func _generate_default_player_name() -> String:
	var rand_code = randi() % 10000
	return "Name%04d" % rand_code

func set_player_name(new_name: String) -> void:
	var trimmed = new_name.strip_edges()
	var old_name = player_name
	if not trimmed.is_empty():
		player_name = trimmed
	else:
		if player_name.is_empty():
			player_name = _generate_default_player_name()
	save_progress()
	sync_score_to_sheets(old_name)

func set_sound_muted(muted: bool) -> void:
	is_sound_muted = muted
	var master_bus_idx = AudioServer.get_bus_index("Master")
	if master_bus_idx != -1:
		AudioServer.set_bus_mute(master_bus_idx, is_sound_muted)
	save_progress()

func set_current_materi(index: int) -> void:
	current_materi_index = index

func set_current_latihan(index: int) -> void:
	current_latihan_index = index

func add_star(count: int = 1) -> void:
	total_stars += count
	save_progress()
	sync_score_to_sheets()

func complete_stage(stage_num: int) -> void:
	cleared_stages[str(stage_num)] = true
	cleared_stages[stage_num] = true
	if stage_num >= max_unlocked_stage:
		max_unlocked_stage = stage_num + 1
	save_progress()

func is_stage_cleared(stage_num: int) -> bool:
	return cleared_stages.has(str(stage_num)) or cleared_stages.has(stage_num)

func is_stage_unlocked(stage_num: int) -> bool:
	return stage_num <= max_unlocked_stage

func get_next_random_question_indices(count: int = 3, total_available: int = 25) -> Array[int]:
	var result: Array[int] = []
	for i in range(count):
		if random_question_indices.is_empty():
			# Replenish with a fresh randomized permutation of 0..total_available-1
			var pool: Array[int] = []
			for idx in range(total_available):
				pool.append(idx)
			pool.shuffle()
			random_question_indices = pool
		result.append(random_question_indices.pop_front())
	return result

func sync_score_to_sheets(old_name: String = "") -> void:
	if not _http_sync_node or GOOGLE_SHEETS_API_URL.is_empty():
		return
		
	var target_name = player_name if not player_name.is_empty() else "Name0000"
	var url = GOOGLE_SHEETS_API_URL
	var sep = "&" if "?" in url else "?"
	url += "%sname=%s&stars=%d" % [sep, target_name.uri_encode(), total_stars]
	if not old_name.is_empty() and old_name != target_name:
		url += "&old_name=%s" % old_name.uri_encode()
	
	var headers = ["Accept: application/json"]
	_http_sync_node.request(url, headers, HTTPClient.METHOD_GET)

func _on_sync_completed(_result: int, _response_code: int, _headers: PackedStringArray, _body: PackedByteArray) -> void:
	pass # Background sync finished silently

func save_progress() -> void:
	var cleared_keys: Array = []
	for k in cleared_stages.keys():
		cleared_keys.append(int(k))
		
	var data = {
		"player_name": player_name,
		"is_sound_muted": is_sound_muted,
		"total_stars": total_stars,
		"current_stage_level": current_stage_level,
		"max_unlocked_stage": max_unlocked_stage,
		"cleared_stages": cleared_keys
	}
	var file = FileAccess.open(SAVE_FILE_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(data))
		file.close()

func load_progress() -> void:
	if not FileAccess.file_exists(SAVE_FILE_PATH):
		return
	var file = FileAccess.open(SAVE_FILE_PATH, FileAccess.READ)
	if not file:
		return
	var content = file.get_as_text()
	file.close()
	
	var json = JSON.new()
	if json.parse(content) == OK:
		var data = json.get_data()
		if data is Dictionary:
			player_name = str(data.get("player_name", "")).strip_edges()
			is_sound_muted = data.get("is_sound_muted", false)
			total_stars = int(data.get("total_stars", 0))
			current_stage_level = int(data.get("current_stage_level", 1))
			max_unlocked_stage = int(data.get("max_unlocked_stage", 1))
			
			var cl = data.get("cleared_stages", [])
			cleared_stages.clear()
			if cl is Array:
				for stage in cl:
					cleared_stages[str(stage)] = true
					cleared_stages[int(stage)] = true
			
			# Apply sound state to audio server
			var master_bus_idx = AudioServer.get_bus_index("Master")
			if master_bus_idx != -1:
				AudioServer.set_bus_mute(master_bus_idx, is_sound_muted)
