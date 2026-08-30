extends Node

# Audio Streams
const BGM_PATH = "res://sounds/massobeats - rose water royalty free lofi music.mp3"
const CLICK_PATH = "res://sounds/Click Sound Effect.mp3"
const CORRECT_PATH = "res://sounds/CorrectAnswer.mp3"
const WRONG_PATH = "res://sounds/WrongAnswer.mp3"
const COMPLETE_PATH = "res://sounds/YaySoundEffect.mp3"

var bgm_player: AudioStreamPlayer
var click_player: AudioStreamPlayer
var correct_player: AudioStreamPlayer
var wrong_player: AudioStreamPlayer
var complete_player: AudioStreamPlayer
var dub_player: AudioStreamPlayer

# Volume settings (linear scale 0.0 - 1.0)
var bgm_volume: float = 0.40 # 40% overall sound
var sfx_volume: float = 0.50 # 50% click sound
var correct_volume: float = 0.40 # 40% correct answer sound
var wrong_volume: float = 0.40 # 40% wrong answer sound
var complete_volume: float = 0.50 # 50% stage complete sound
var dub_volume: float = 0.95 # 95% voice/dub question sound

var is_sound_muted: bool = false

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS # Persist and play across pauses/scenes
	_setup_bgm_player()
	_setup_sfx_players()
	
	# Hook into scene tree to automatically attach click sound to all buttons
	get_tree().node_added.connect(_on_node_added)
	_scan_and_hook_buttons(get_tree().root)
	
	# Load muted state from PlayerData if available
	var pd = get_node_or_null("/root/PlayerData")
	if pd and "is_sound_muted" in pd:
		is_sound_muted = pd.is_sound_muted
	apply_mute_setting(is_sound_muted)

func _setup_bgm_player() -> void:
	bgm_player = AudioStreamPlayer.new()
	bgm_player.name = "BGMPlayer"
	
	if ResourceLoader.exists(BGM_PATH):
		var bgm_stream = load(BGM_PATH)
		if bgm_stream is AudioStreamMP3:
			bgm_stream.loop = true
		bgm_player.stream = bgm_stream
		
	bgm_player.volume_db = linear_to_db(bgm_volume)
	add_child(bgm_player)

func _create_sfx_player(path: String, player_name: String, volume_linear: float) -> AudioStreamPlayer:
	var player = AudioStreamPlayer.new()
	player.name = player_name
	
	if ResourceLoader.exists(path):
		var stream = load(path)
		if stream is AudioStreamMP3:
			stream.loop = false
		player.stream = stream
		
	player.volume_db = linear_to_db(volume_linear)
	add_child(player)
	return player

func _setup_sfx_players() -> void:
	click_player = _create_sfx_player(CLICK_PATH, "ClickPlayer", sfx_volume)
	correct_player = _create_sfx_player(CORRECT_PATH, "CorrectPlayer", correct_volume)
	wrong_player = _create_sfx_player(WRONG_PATH, "WrongPlayer", wrong_volume)
	complete_player = _create_sfx_player(COMPLETE_PATH, "CompletePlayer", complete_volume)
	
	dub_player = AudioStreamPlayer.new()
	dub_player.name = "DubPlayer"
	dub_player.volume_db = linear_to_db(dub_volume)
	add_child(dub_player)

func set_sound_muted(muted: bool) -> void:
	is_sound_muted = muted
	apply_mute_setting(muted)

func apply_mute_setting(muted: bool) -> void:
	is_sound_muted = muted
	
	# Keep Master bus unmuted at all times so Quiz Sound is never affected
	var master_bus_idx = AudioServer.get_bus_index("Master")
	if master_bus_idx != -1:
		AudioServer.set_bus_mute(master_bus_idx, false)
		
	if is_sound_muted:
		if bgm_player and bgm_player.playing:
			bgm_player.stop()
	else:
		play_bgm()

func play_bgm() -> void:
	if is_sound_muted:
		return
	if bgm_player and bgm_player.stream:
		if not bgm_player.playing:
			bgm_player.play()

func stop_bgm() -> void:
	if bgm_player and bgm_player.playing:
		bgm_player.stop()

func set_bgm_volume(linear_vol: float) -> void:
	bgm_volume = clamp(linear_vol, 0.0, 1.0)
	if bgm_player:
		bgm_player.volume_db = linear_to_db(bgm_volume)

func set_correct_volume(linear_vol: float) -> void:
	correct_volume = clamp(linear_vol, 0.0, 1.0)
	if correct_player:
		correct_player.volume_db = linear_to_db(correct_volume)

func set_wrong_volume(linear_vol: float) -> void:
	wrong_volume = clamp(linear_vol, 0.0, 1.0)
	if wrong_player:
		wrong_player.volume_db = linear_to_db(wrong_volume)

func set_sfx_volume(linear_vol: float) -> void:
	sfx_volume = clamp(linear_vol, 0.0, 1.0)
	if click_player:
		click_player.volume_db = linear_to_db(sfx_volume)
	if correct_player:
		correct_player.volume_db = linear_to_db(correct_volume)
	if wrong_player:
		wrong_player.volume_db = linear_to_db(wrong_volume)
	if complete_player:
		complete_player.volume_db = linear_to_db(complete_volume)

func set_dub_volume(linear_vol: float) -> void:
	dub_volume = clamp(linear_vol, 0.0, 1.0)
	if dub_player:
		dub_player.volume_db = linear_to_db(dub_volume)

func play_click() -> void:
	if is_sound_muted:
		return
	if click_player and click_player.stream:
		click_player.play()

func play_correct() -> void:
	if is_sound_muted:
		return
	if correct_player and correct_player.stream:
		correct_player.stop()
		correct_player.play()

func play_wrong() -> void:
	if is_sound_muted:
		return
	if wrong_player and wrong_player.stream:
		wrong_player.stop()
		wrong_player.play()

func play_stage_complete() -> void:
	if is_sound_muted:
		return
	if complete_player and complete_player.stream:
		complete_player.stop()
		complete_player.play()

func play_complete() -> void:
	play_stage_complete()

func play_yay() -> void:
	play_stage_complete()

func play_dub(sound_resource_or_path: Variant) -> void:
	# Ensure Master Bus is active and unmuted for quiz dub sound
	var master_bus_idx = AudioServer.get_bus_index("Master")
	if master_bus_idx != -1 and AudioServer.is_bus_mute(master_bus_idx):
		AudioServer.set_bus_mute(master_bus_idx, false)
		
	if not dub_player:
		return
	if dub_player.playing:
		dub_player.stop()
		
	var stream: AudioStream = null
	if sound_resource_or_path is AudioStream:
		stream = sound_resource_or_path
	elif sound_resource_or_path is String and not str(sound_resource_or_path).is_empty():
		var path_str: String = str(sound_resource_or_path)
		if ResourceLoader.exists(path_str):
			stream = load(path_str)
			
	if stream:
		if stream is AudioStreamMP3:
			stream.loop = false
		dub_player.stream = stream
		dub_player.volume_db = linear_to_db(dub_volume)
		dub_player.play()

func stop_dub() -> void:
	if dub_player and dub_player.playing:
		dub_player.stop()

# Auto-hook all buttons across the application
func _on_node_added(node: Node) -> void:
	if node is BaseButton:
		_hook_button(node)

func _hook_button(btn: BaseButton) -> void:
	if btn.is_in_group("no_click_sound") or btn.name in ["BtnPeriksaChoice", "BtnPeriksaDraw", "BtnPlaySound"]:
		return
	if not btn.pressed.is_connected(play_click):
		btn.pressed.connect(play_click)

func _scan_and_hook_buttons(node: Node) -> void:
	if node is BaseButton:
		_hook_button(node)
	for child in node.get_children():
		_scan_and_hook_buttons(child)
