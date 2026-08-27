extends Control

@export_group("Google Sheets Leaderboard API")
@export var google_sheets_api_url: String = "https://script.google.com/macros/s/AKfycbzRUlJcvnjKqHNKmLmIwXj03vQGfacKX4ZwIrItm81CzVZMVVek01Q3BNBzvOBphWQhOg/exec"

# UI Nodes
@onready var btn_kembali: TextureButton = $FooterLayer/BtnKembali
@onready var scroll_container: ScrollContainer = $ScrollContainer
@onready var list_container: VBoxContainer = $ScrollContainer/ListContainer
@onready var my_rank_container: Control = $MyRankContainer
@onready var loading_label: Label = $LoadingLabel

# HTTP Request Nodes
@onready var http_request_get: HTTPRequest = $HTTPRequestGet
@onready var http_request_post: HTTPRequest = $HTTPRequestPost

# Textures & Fonts
var TEX_PLANK: Texture2D = null
var TEX_BADGE_1: Texture2D = null
var TEX_BADGE_2: Texture2D = null
var TEX_BADGE_3: Texture2D = null
var TEX_BADGE_PLACEHOLDER: Texture2D = null
var FONT_SIGMAR: FontFile = null

const COLOR_PLACEHOLDER_TEXT = Color("#CFBA98")
const COLOR_TEXT_DARK = Color(0.24, 0.14, 0.07, 1.0) # #3E2312

func _get_player_data() -> Node:
	var root_node = null
	if is_inside_tree() and get_tree() and get_tree().root:
		root_node = get_tree().root
	else:
		var tree = Engine.get_main_loop() as SceneTree
		if tree and tree.root:
			root_node = tree.root
			
	if root_node:
		var pd_node = root_node.get_node_or_null("PlayerData")
		if pd_node:
			return pd_node
		for child in root_node.get_children():
			if str(child.name) == "PlayerData":
				return child
	return get_node_or_null("/root/PlayerData")

func _ready() -> void:
	# Load assets
	TEX_PLANK = load("res://assets/LeaderBoard.png")
	TEX_BADGE_1 = load("res://assets/Leader1.png")
	TEX_BADGE_2 = load("res://assets/Leader2.png")
	TEX_BADGE_3 = load("res://assets/Leader3.png")
	TEX_BADGE_PLACEHOLDER = load("res://assets/LeadPlaceholder.png")
	FONT_SIGMAR = load("res://assets/fonts/Sigmar-Regular.ttf")
	
	# Setup button
	_setup_button_effects(btn_kembali)
	if btn_kembali and not btn_kembali.pressed.is_connected(_on_kembali_pressed):
		btn_kembali.pressed.connect(_on_kembali_pressed)
		
	# Hide scrollbar for clean UI
	if scroll_container:
		var v_scroll = scroll_container.get_v_scroll_bar()
		if v_scroll:
			v_scroll.modulate.a = 0.0
			
	# Connect HTTP signals
	if http_request_get:
		http_request_get.request_completed.connect(_on_http_get_completed)
	if http_request_post:
		http_request_post.request_completed.connect(_on_http_post_completed)
		
	# Auto submit local player score and fetch leaderboard
	_sync_and_fetch_leaderboard()

func _sync_and_fetch_leaderboard() -> void:
	if loading_label:
		loading_label.visible = true
		loading_label.text = "Memuat Peringkat..."
		
	if google_sheets_api_url.strip_edges().is_empty():
		print("Google Sheets API URL is empty. Loading default leaderboard data.")
		_display_default_leaderboard()
		return
		
	var pd = _get_player_data()
	var current_name = pd.player_name if (pd and not pd.player_name.is_empty()) else "Arma"
	var current_stars = pd.total_stars if pd else 0
	
	# Send GET request (with query params if stars > 0 for 1-step update + fetch)
	var url = google_sheets_api_url
	if current_stars > 0:
		var sep = "&" if "?" in url else "?"
		url += "%sname=%s&stars=%d" % [sep, current_name.uri_encode(), current_stars]
		
	var headers = ["Accept: application/json"]
	var err = http_request_get.request(url, headers, HTTPClient.METHOD_GET)
	if err != OK:
		print("Failed to start HTTP GET request: %d" % err)
		_display_default_leaderboard()

func _on_http_get_completed(_result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	if loading_label:
		loading_label.visible = false
		
	if response_code == 200 or response_code == 302:
		var response_text = body.get_string_from_utf8()
		var json = JSON.new()
		var parse_err = json.parse(response_text)
		if parse_err == OK and json.data is Dictionary:
			var data_array = json.data.get("data", [])
			if data_array is Array and not data_array.is_empty():
				_render_leaderboard_rows(data_array)
				return
				
	print("HTTP GET failed or empty (Response Code %d). Falling back to default data." % response_code)
	_display_default_leaderboard()

func _on_http_post_completed(_result: int, _response_code: int, _headers: PackedStringArray, _body: PackedByteArray) -> void:
	pass

func _display_default_leaderboard() -> void:
	if loading_label:
		loading_label.visible = false
		
	var pd = _get_player_data()
	var current_player_name = pd.player_name if (pd and not pd.player_name.is_empty()) else "Arma"
	var current_player_stars = pd.total_stars if pd else 0
	
	# Default mockup entries matching design
	var mock_entries = [
		{"name": "sances", "stars": 100},
		{"name": "sances", "stars": 90},
		{"name": "sances", "stars": 80},
		{"name": "sances", "stars": 70},
		{"name": current_player_name, "stars": current_player_stars},
		{"name": "sances", "stars": 50}
	]
	
	_render_leaderboard_rows(mock_entries)

func _create_leaderboard_row(rank_str: String, player_name: String, stars_count: int, is_highlighted: bool = false) -> Control:
	var row = Control.new()
	row.custom_minimum_size = Vector2(980, 148)
	row.size = Vector2(980, 148)
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	# Wooden Plank Background
	var plank = TextureRect.new()
	plank.texture = TEX_PLANK
	plank.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	plank.stretch_mode = TextureRect.STRETCH_SCALE
	plank.size = Vector2(980, 138)
	plank.position = Vector2(0, 5)
	plank.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	if is_highlighted:
		# Subtle bright warm highlight for player's own row
		plank.modulate = Color(1.05, 1.02, 0.95, 1.0)
		
	row.add_child(plank)
	
	# Badge Icon
	var badge = TextureRect.new()
	badge.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	badge.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	badge.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	if rank_str == "1":
		badge.texture = TEX_BADGE_1
		badge.size = Vector2(146, 146)
		badge.position = Vector2(8, 0)
	elif rank_str == "2":
		badge.texture = TEX_BADGE_2
		badge.size = Vector2(148, 148)
		badge.position = Vector2(8, 0)
	elif rank_str == "3":
		badge.texture = TEX_BADGE_3
		badge.size = Vector2(140, 140)
		badge.position = Vector2(12, 4)
	else:
		badge.texture = TEX_BADGE_PLACEHOLDER
		badge.size = Vector2(136, 136)
		badge.position = Vector2(14, 6)
		
		# Rank Number / Dash inside placeholder badge with exact color #CFBA98
		var lbl_rank = Label.new()
		var rank_settings = LabelSettings.new()
		rank_settings.font = FONT_SIGMAR
		rank_settings.font_size = 40 if rank_str != "-" else 48
		rank_settings.font_color = COLOR_PLACEHOLDER_TEXT
		rank_settings.shadow_size = 3
		rank_settings.shadow_color = Color(0, 0, 0, 0.4)
		lbl_rank.label_settings = rank_settings
		lbl_rank.text = rank_str
		lbl_rank.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		lbl_rank.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		lbl_rank.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		lbl_rank.offset_top = -2.0 if rank_str != "-" else -4.0
		badge.add_child(lbl_rank)
		
	row.add_child(badge)
	
	# Player Name Label
	var lbl_name = Label.new()
	var name_settings = LabelSettings.new()
	name_settings.font = FONT_SIGMAR
	name_settings.font_size = 38
	name_settings.font_color = COLOR_TEXT_DARK
	name_settings.shadow_size = 2
	name_settings.shadow_color = Color(0.9, 0.8, 0.65, 0.4)
	lbl_name.label_settings = name_settings
	lbl_name.text = player_name
	lbl_name.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	lbl_name.position = Vector2(170, 44)
	lbl_name.size = Vector2(500, 55)
	lbl_name.clip_text = true
	row.add_child(lbl_name)
	
	# Stars Score Label
	var lbl_stars = Label.new()
	var stars_settings = LabelSettings.new()
	stars_settings.font = FONT_SIGMAR
	stars_settings.font_size = 42
	stars_settings.font_color = COLOR_TEXT_DARK
	stars_settings.shadow_size = 2
	stars_settings.shadow_color = Color(0.9, 0.8, 0.65, 0.4)
	lbl_stars.label_settings = stars_settings
	lbl_stars.text = str(stars_count)
	lbl_stars.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	lbl_stars.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	lbl_stars.position = Vector2(680, 44)
	lbl_stars.size = Vector2(240, 55)
	row.add_child(lbl_stars)
	
	return row

func _render_leaderboard_rows(entries: Array) -> void:
	# Clear existing children in scroll list and my rank container
	for child in list_container.get_children():
		child.queue_free()
	for child in my_rank_container.get_children():
		child.queue_free()
		
	var pd = _get_player_data()
	var current_player_name = pd.player_name if (pd and not pd.player_name.is_empty()) else "Arma"
	var current_player_stars = pd.total_stars if pd else 0
	
	# Sort all entries descending by stars
	var sorted_entries = entries.duplicate()
	sorted_entries.sort_custom(func(a, b):
		return int(b.get("stars", 0)) < int(a.get("stars", 0))
	)
	
	# 1. Determine Local Player's overall Rank
	var my_rank_str = "-"
	if current_player_stars > 0:
		var found_rank = -1
		for idx in range(sorted_entries.size()):
			var e_name = str(sorted_entries[idx].get("name", "")).strip_edges().to_lower()
			if e_name == current_player_name.strip_edges().to_lower():
				found_rank = idx + 1
				break
		if found_rank > 0:
			my_rank_str = str(found_rank)
		else:
			# If player has stars but is placed lower than fetched list
			my_rank_str = str(sorted_entries.size() + 1)
	else:
		my_rank_str = "-"
		
	# 2. Render Top 10 rows in Scroll Container
	var top_count = min(10, sorted_entries.size())
	for i in range(top_count):
		var entry = sorted_entries[i]
		var rank_str = str(i + 1)
		var p_name = str(entry.get("name", "Player"))
		var p_stars = int(entry.get("stars", 0))
		var is_me = (p_name.strip_edges().to_lower() == current_player_name.strip_edges().to_lower())
		
		var row_node = _create_leaderboard_row(rank_str, p_name, p_stars, is_me)
		list_container.add_child(row_node)
		
	# 3. Render Pinned "My Rank" row at the bottom
	var my_row_node = _create_leaderboard_row(my_rank_str, current_player_name, current_player_stars, true)
	my_rank_container.add_child(my_row_node)

func _on_kembali_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")

func _setup_button_effects(btn: TextureButton) -> void:
	if not btn:
		return
	btn.button_down.connect(func():
		var tween = create_tween()
		tween.tween_property(btn, "scale", Vector2(0.93, 0.93), 0.08).set_trans(Tween.TRANS_QUAD)
	)
	btn.button_up.connect(func():
		var tween = create_tween()
		tween.tween_property(btn, "scale", Vector2(1.0, 1.0), 0.12).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	)
	btn.mouse_entered.connect(func():
		var tween = create_tween()
		tween.tween_property(btn, "scale", Vector2(1.04, 1.04), 0.15).set_trans(Tween.TRANS_SINE)
	)
	btn.mouse_exited.connect(func():
		var tween = create_tween()
		tween.tween_property(btn, "scale", Vector2(1.0, 1.0), 0.15).set_trans(Tween.TRANS_SINE)
	)
