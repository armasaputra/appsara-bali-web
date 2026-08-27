extends Control

# Main Menu UI Nodes
@onready var label_greeting: Label = $LabelGreeting
@onready var avatar_container: Control = $AvatarContainer
@onready var btn_settings: TextureButton = $BtnSettings

@onready var btn_belajar: TextureButton = $GridMenu/BtnBelajar
@onready var btn_materi: TextureButton = $GridMenu/BtnMateri
@onready var btn_latihan: TextureButton = $GridMenu/BtnLatihan
@onready var btn_peringkat: TextureButton = $GridMenu/BtnPeringkat

# Settings Popup UI Nodes
@onready var setting_popup_layer: Control = $SettingPopupLayer
@onready var popup_container: Control = $SettingPopupLayer/PopupContainer
@onready var btn_close: TextureButton = $SettingPopupLayer/PopupContainer/PopupFrame/BtnClose
@onready var line_edit_name: LineEdit = $SettingPopupLayer/PopupContainer/PopupFrame/InputFieldBg/LineEditName
@onready var btn_sound: TextureButton = $SettingPopupLayer/PopupContainer/PopupFrame/BtnSound
@onready var btn_terapkan: TextureButton = $SettingPopupLayer/PopupContainer/BtnTerapkan

# Textures
const TEX_SOUND_ON = preload("res://assets/SoundOn.png")
const TEX_SOUND_OFF = preload("res://assets/SoundOff.png")

# Modal state
var _temp_sound_muted: bool = false
var _is_popup_open: bool = false

func _ready() -> void:
	# Update greeting
	_update_greeting()
	
	# Hide popup initially
	setting_popup_layer.visible = false
	_is_popup_open = false
	
	# Setup main menu button animations and callbacks
	_setup_button(btn_settings, _on_settings_pressed)
	_setup_button(btn_belajar, _on_belajar_pressed)
	_setup_button(btn_materi, _on_materi_pressed)
	_setup_button(btn_latihan, _on_latihan_pressed)
	_setup_button(btn_peringkat, _on_peringkat_pressed)
	
	# Setup popup button animations and callbacks
	_setup_button(btn_close, _on_close_pressed)
	_setup_button(btn_sound, _on_sound_pressed)
	_setup_button(btn_terapkan, _on_terapkan_pressed)
	
	# LineEdit enter key submits/applies
	line_edit_name.text_submitted.connect(func(_text): _on_terapkan_pressed())
	
	# Gentle idle breathing animation for avatar
	_start_avatar_idle()

func _update_greeting() -> void:
	var pd = get_node_or_null("/root/PlayerData")
	if pd and not pd.player_name.is_empty():
		label_greeting.text = "Haiii " + pd.player_name + "."
	else:
		label_greeting.text = "Haiii Arma."

func _setup_button(btn: TextureButton, callback: Callable) -> void:
	btn.pressed.connect(callback)
	btn.button_down.connect(func():
		var tween = create_tween()
		tween.tween_property(btn, "scale", Vector2(0.92, 0.92), 0.08).set_trans(Tween.TRANS_QUAD)
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

func _start_avatar_idle() -> void:
	var initial_y = avatar_container.position.y
	var tween = create_tween().set_loops()
	tween.tween_property(avatar_container, "position:y", initial_y - 8.0, 2.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(avatar_container, "position:y", initial_y, 2.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

# ==========================================
# SETTINGS POPUP LOGIC
# ==========================================

func _on_settings_pressed() -> void:
	_is_popup_open = true
	
	# Load current saved settings into temporary state
	var pd = get_node_or_null("/root/PlayerData")
	if pd:
		line_edit_name.text = pd.player_name
		_temp_sound_muted = pd.is_sound_muted
	else:
		line_edit_name.text = "Arma"
		_temp_sound_muted = false
	
	_update_sound_icon()
	
	# Animate popup open
	setting_popup_layer.visible = true
	setting_popup_layer.modulate.a = 0.0
	popup_container.scale = Vector2(0.7, 0.7)
	
	var tween = create_tween().set_parallel(true)
	tween.tween_property(setting_popup_layer, "modulate:a", 1.0, 0.22)
	tween.tween_property(popup_container, "scale", Vector2.ONE, 0.32).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

func _on_sound_pressed() -> void:
	# Toggle temporary sound muted state
	_temp_sound_muted = !_temp_sound_muted
	_update_sound_icon()

func _update_sound_icon() -> void:
	if _temp_sound_muted:
		btn_sound.texture_normal = TEX_SOUND_OFF
	else:
		btn_sound.texture_normal = TEX_SOUND_ON

func _on_close_pressed() -> void:
	# Discard changes and close
	_close_popup()

func _on_terapkan_pressed() -> void:
	# Apply changes to PlayerData
	var pd = get_node_or_null("/root/PlayerData")
	if pd:
		var entered_name = line_edit_name.text.strip_edges()
		pd.set_player_name(entered_name)
		pd.set_sound_muted(_temp_sound_muted)
	
	_update_greeting()
	_close_popup()

func _close_popup() -> void:
	_is_popup_open = false
	var tween = create_tween().set_parallel(true)
	tween.tween_property(setting_popup_layer, "modulate:a", 0.0, 0.18)
	tween.tween_property(popup_container, "scale", Vector2(0.75, 0.75), 0.18).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tween.chain().tween_callback(func():
		if not _is_popup_open:
			setting_popup_layer.visible = false
	)

# ==========================================
# MAIN MENU NAVIGATION
# ==========================================

func _on_belajar_pressed() -> void:
	print("Menu Belajar Bertahap dipilih!")
	var pd = get_node_or_null("/root/PlayerData")
	if pd:
		pd.is_gameplay_mode = true
	get_tree().change_scene_to_file("res://scenes/Gameplay.tscn")

func _on_materi_pressed() -> void:
	print("Menu DAFTAR MATERI dipilih!")
	get_tree().change_scene_to_file("res://scenes/Materi.tscn")

func _on_latihan_pressed() -> void:
	print("Menu Latihan dipilih!")
	get_tree().change_scene_to_file("res://scenes/Latihan.tscn")

func _on_peringkat_pressed() -> void:
	print("Menu Papan Peringkat dipilih!")

