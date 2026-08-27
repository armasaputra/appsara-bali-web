extends Control

# Header Nodes
@onready var label_title: Label = $HeaderLayer/TitleBoard/LabelTitle
@onready var star_board: TextureRect = $HeaderLayer/StarBoard
@onready var label_total_stars: Label = $HeaderLayer/StarBoard/LabelStars

# Footer Nodes
@onready var btn_mulai: TextureButton = $FooterLayer/BtnMulai
@onready var btn_kembali: TextureButton = $FooterLayer/BtnKembali

# Scroll & Map Nodes
@onready var scroll_container: ScrollContainer = $ScrollContainer
@onready var map_content: Control = $ScrollContainer/MapContent

# Textures (loaded dynamically)
var TEX_ROAD: Texture2D = null
var TEX_STAGE_CLEARED: Texture2D = null
var TEX_STAGE_NOT_CLEARED: Texture2D = null
var TEX_AVATAR: Texture2D = null
var FONT_SIGMAR: FontFile = null

@export_group("Stage Road Configuration")
## Position (X, Y) of the 5 stage platforms relative to each 1080x1191 road tile
@export var stage_local_offsets: Array[Vector2] = [
	Vector2(377, 870),  # Stage 1 (bottom loop disk)
	Vector2(576, 675),  # Stage 2 (mid-center loop disk)
	Vector2(883, 471),  # Stage 3 (mid-right loop disk)
	Vector2(225, 390),  # Stage 4 (upper-left loop disk)
	Vector2(474, 205)   # Stage 5 (top loop disk)
]

@export var chunk_height: float = 1191.0
@export var chunk_step: float = 1010.0 # Pixel-perfect overlap between repeating road tiles
@export var bottom_padding: float = 450.0
@export var top_padding: float = 450.0

@export_group("Platform & Avatar Sizes")
## Size (width, height) of each stage disk platform
@export var platform_size: Vector2 = Vector2(180, 180)
## Font size for the stage number text
@export var stage_font_size: int = 32
## Vertical offset to align the stage number text inside the platform disk
@export var stage_number_offset_y: float = 22.0
## Size (width, height) of the player avatar standing on the active stage
@export var avatar_size: Vector2 = Vector2(120, 155)
## Vertical offset to position the avatar's feet on top of the platform
@export var avatar_offset_y: float = 85.0

# Avatar reference
var avatar_sprite: TextureRect = null
var avatar_tween: Tween = null
var current_active_stage_num: int = 1
var stage_positions: Dictionary = {} # stage_num -> Vector2

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
	if not TEX_ROAD:
		TEX_ROAD = load("res://assets/Roadpath.png")
	if not TEX_STAGE_CLEARED:
		TEX_STAGE_CLEARED = load("res://assets/StageCleared.png")
	if not TEX_STAGE_NOT_CLEARED:
		TEX_STAGE_NOT_CLEARED = load("res://assets/StageNotCleared.png")
	if not TEX_AVATAR:
		TEX_AVATAR = load("res://assets/AvatarPlayerStage.png")
	if not FONT_SIGMAR:
		FONT_SIGMAR = load("res://assets/fonts/Sigmar-Regular.ttf")
		
	var pd = _get_player_data()
	if pd:
		pd.is_gameplay_mode = true
		if pd.current_stage_level > 0:
			current_active_stage_num = pd.current_stage_level
		else:
			current_active_stage_num = 1
	else:
		current_active_stage_num = 1
		
	_update_header_stars()
	_setup_button_effects(btn_mulai)
	_setup_button_effects(btn_kembali)
	
	if btn_mulai and not btn_mulai.pressed.is_connected(_on_mulai_pressed):
		btn_mulai.pressed.connect(_on_mulai_pressed)
	if btn_kembali and not btn_kembali.pressed.is_connected(_on_kembali_pressed):
		btn_kembali.pressed.connect(_on_kembali_pressed)
		
	_build_endless_map()
	
	# Scroll smoothly to active stage
	call_deferred("_scroll_to_active_stage", false)

func _update_header_stars() -> void:
	var pd = _get_player_data()
	if label_total_stars and pd:
		label_total_stars.text = str(pd.total_stars)

func _build_endless_map() -> void:
	# Clear existing map content children
	for child in map_content.get_children():
		child.queue_free()
	stage_positions.clear()
	
	var pd = _get_player_data()
	var current_stage = pd.current_stage_level if pd else 1
	
	# Show enough stages ahead of player
	var total_stages = max(15, int(ceil((current_stage + 6) / 5.0) * 5.0))
	var total_chunks = int(ceil(float(total_stages) / 5.0))
	
	var total_height = float(total_chunks) * chunk_step + bottom_padding + top_padding
	
	map_content.custom_minimum_size = Vector2(1080, total_height)
	map_content.size = Vector2(1080, total_height)
	
	# PASS 1: Build ALL road chunks from bottom to top first (so they stay in the background)
	for chunk_idx in range(total_chunks):
		var road_y = total_height - bottom_padding - float(chunk_idx + 1) * chunk_step
		
		# Road path sprite
		var road_rect = TextureRect.new()
		road_rect.texture = TEX_ROAD
		road_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		road_rect.stretch_mode = TextureRect.STRETCH_SCALE
		road_rect.size = Vector2(1080, chunk_height)
		road_rect.position = Vector2(0, road_y)
		road_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
		map_content.add_child(road_rect)
		
	# PASS 2: Build ALL stage platforms on top of the roads
	for chunk_idx in range(total_chunks):
		var road_y = total_height - bottom_padding - float(chunk_idx + 1) * chunk_step
		for stage_in_chunk in range(5):
			var stage_num = chunk_idx * 5 + stage_in_chunk + 1
			var offset_pos = stage_local_offsets[stage_in_chunk] if stage_in_chunk < stage_local_offsets.size() else Vector2(540, 540)
			var global_stage_pos = Vector2(offset_pos.x, road_y + offset_pos.y)
			
			stage_positions[stage_num] = global_stage_pos
			
			var is_cleared = (stage_num < current_stage) or (pd and pd.is_stage_cleared(stage_num))
			
			# Stage Platform (non-replayable, visual progression)
			var platform = TextureRect.new()
			platform.texture = TEX_STAGE_CLEARED if is_cleared else TEX_STAGE_NOT_CLEARED
			platform.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			platform.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			platform.custom_minimum_size = platform_size
			platform.size = platform_size
			platform.pivot_offset = platform_size * 0.5
			platform.position = global_stage_pos - platform_size * 0.5
			platform.mouse_filter = Control.MOUSE_FILTER_IGNORE
			
			# Stage Number Label
			var lbl_num = Label.new()
			var lbl_settings = LabelSettings.new()
			lbl_settings.font = FONT_SIGMAR
			lbl_settings.font_size = stage_font_size
			lbl_settings.font_color = Color(1.0, 0.95, 0.8) if is_cleared else Color(0.85, 0.85, 0.85)
			lbl_settings.shadow_size = 4
			lbl_settings.shadow_color = Color(0, 0, 0, 0.5)
			lbl_num.label_settings = lbl_settings
			lbl_num.text = str(stage_num)
			lbl_num.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			lbl_num.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
			lbl_num.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
			lbl_num.offset_top = stage_number_offset_y # center nicely inside platform disk
			platform.add_child(lbl_num)
			
			map_content.add_child(platform)
			
	# PASS 3: Create and place Avatar Node on top of all platforms
	avatar_sprite = TextureRect.new()
	avatar_sprite.texture = TEX_AVATAR
	avatar_sprite.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	avatar_sprite.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	avatar_sprite.size = avatar_size
	avatar_sprite.pivot_offset = Vector2(avatar_size.x * 0.5, avatar_size.y)
	avatar_sprite.mouse_filter = Control.MOUSE_FILTER_IGNORE
	map_content.add_child(avatar_sprite)
	
	_position_avatar_at_stage(current_active_stage_num)

func _position_avatar_at_stage(stage_num: int) -> void:
	if not stage_positions.has(stage_num) or not avatar_sprite:
		return
		
	var target_stage_pos = stage_positions[stage_num]
	# Avatar feet stand right on the platform surface
	var target_pos = target_stage_pos - Vector2(avatar_size.x * 0.5, avatar_size.y + avatar_offset_y - platform_size.y * 0.5)
	
	if avatar_tween:
		avatar_tween.kill()
		
	avatar_sprite.position = target_pos
	_start_avatar_idle()

func _start_avatar_idle() -> void:
	if not avatar_sprite:
		return
	if avatar_tween:
		avatar_tween.kill()
		
	var base_y = avatar_sprite.position.y
	avatar_tween = create_tween().set_loops()
	avatar_tween.tween_property(avatar_sprite, "position:y", base_y - 10.0, 0.8).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	avatar_tween.tween_property(avatar_sprite, "position:y", base_y, 0.8).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

func _scroll_to_active_stage(animated: bool = true) -> void:
	if not stage_positions.has(current_active_stage_num) or not scroll_container:
		return
		
	var stage_y = stage_positions[current_active_stage_num].y
	var viewport_h = 1920.0
	var target_scroll_v = int(clamp(stage_y - viewport_h * 0.5, 0.0, float(map_content.custom_minimum_size.y - viewport_h)))
	
	if animated:
		var tween = create_tween()
		tween.tween_property(scroll_container, "scroll_vertical", target_scroll_v, 0.45).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	else:
		scroll_container.scroll_vertical = target_scroll_v

func _on_mulai_pressed() -> void:
	print("Memulai Belajar Bertahap Level: %d" % current_active_stage_num)
	var pd = _get_player_data()
	if pd:
		pd.is_gameplay_mode = true
		pd.current_stage_level = current_active_stage_num
		pd.set_current_latihan(current_active_stage_num)
	get_tree().change_scene_to_file("res://scenes/IsiLatihan.tscn")

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
