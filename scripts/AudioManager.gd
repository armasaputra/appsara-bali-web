extends Node

# Audio Streams
const BGM_PATH = "res://sounds/massobeats - rose water royalty free lofi music.mp3"
const CLICK_PATH = "res://sounds/Click Sound Effect.mp3"

var bgm_player: AudioStreamPlayer
var click_player: AudioStreamPlayer

# Volume settings (linear scale 0.0 - 1.0)
var bgm_volume: float = 0.40 # 40% overall sound
var sfx_volume: float = 0.50 # 50% overall sound

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS # Persist and play across pauses/scenes
	_setup_bgm_player()
	_setup_click_player()
	
	# Hook into scene tree to automatically attach click sound to all buttons
	get_tree().node_added.connect(_on_node_added)
	_scan_and_hook_buttons(get_tree().root)
	
	# Start background music
	play_bgm()

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

func _setup_click_player() -> void:
	click_player = AudioStreamPlayer.new()
	click_player.name = "ClickPlayer"
	
	if ResourceLoader.exists(CLICK_PATH):
		var click_stream = load(CLICK_PATH)
		click_player.stream = click_stream
		
	click_player.volume_db = linear_to_db(sfx_volume)
	add_child(click_player)

func play_bgm() -> void:
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

func set_sfx_volume(linear_vol: float) -> void:
	sfx_volume = clamp(linear_vol, 0.0, 1.0)
	if click_player:
		click_player.volume_db = linear_to_db(sfx_volume)

func play_click() -> void:
	if click_player and click_player.stream:
		click_player.play()

# Auto-hook all buttons across the application
func _on_node_added(node: Node) -> void:
	if node is BaseButton:
		_hook_button(node)

func _hook_button(btn: BaseButton) -> void:
	if not btn.pressed.is_connected(play_click):
		btn.pressed.connect(play_click)

func _scan_and_hook_buttons(node: Node) -> void:
	if node is BaseButton:
		_hook_button(node)
	for child in node.get_children():
		_scan_and_hook_buttons(child)
