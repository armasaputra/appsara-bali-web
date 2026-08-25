extends Control

enum State { MULAI, INPUT_NAME, NAME_SAVED }
var current_state: State = State.MULAI

@onready var character: TextureRect = $Character
@onready var aksara_title: TextureRect = $AksaraTitle
@onready var tulisan_bali: TextureRect = $TulisanAksaraBali
@onready var name_input_panel: TextureRect = $NameInputPanel
@onready var line_edit_name: LineEdit = $NameInputPanel/LineEditName
@onready var wood_popup_panel: TextureRect = $WoodPopUpPanel
@onready var label_popup: Label = $WoodPopUpPanel/LabelPopup
@onready var action_button: TextureButton = $ActionButton
@onready var label_action: Label = $ActionButton/LabelAction

var initial_char_pos_y: float = 0.0

func _ready() -> void:
	initial_char_pos_y = character.position.y
	_start_idle_animation()
	
	action_button.pressed.connect(_on_action_button_pressed)
	action_button.button_down.connect(_on_action_button_down)
	action_button.button_up.connect(_on_action_button_up)
	line_edit_name.text_submitted.connect(_on_name_submitted)
	
	# Initial UI state setup
	name_input_panel.visible = false
	wood_popup_panel.visible = false
	label_action.text = "Mulai"

func _start_idle_animation() -> void:
	var tween = create_tween().set_loops()
	tween.tween_property(character, "position:y", initial_char_pos_y - 10.0, 2.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(character, "position:y", initial_char_pos_y, 2.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

func _on_action_button_down() -> void:
	var tween = create_tween()
	tween.tween_property(action_button, "scale", Vector2(0.93, 0.93), 0.08).set_trans(Tween.TRANS_QUAD)

func _on_action_button_up() -> void:
	var tween = create_tween()
	tween.tween_property(action_button, "scale", Vector2(1.0, 1.0), 0.12).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

func _on_action_button_pressed() -> void:
	match current_state:
		State.MULAI:
			_show_name_input()
		State.INPUT_NAME:
			_save_name()
		State.NAME_SAVED:
			_go_to_main_menu()

func _show_name_input() -> void:
	current_state = State.INPUT_NAME
	
	_animate_button_text("Simpan")
	
	name_input_panel.visible = true
	name_input_panel.scale = Vector2(0.7, 0.7)
	name_input_panel.modulate.a = 0.0
	
	var tween = create_tween().set_parallel(true)
	tween.tween_property(name_input_panel, "modulate:a", 1.0, 0.25)
	tween.tween_property(name_input_panel, "scale", Vector2.ONE, 0.35).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	
	await get_tree().create_timer(0.35).timeout
	line_edit_name.grab_focus()

func _on_name_submitted(_new_text: String) -> void:
	if current_state == State.INPUT_NAME:
		_save_name()

func _save_name() -> void:
	var entered_name = line_edit_name.text.strip_edges()
	if entered_name.is_empty():
		entered_name = "Arma"
	
	var pd = get_node_or_null("/root/PlayerData")
	if pd and pd.has_method("set_player_name"):
		pd.set_player_name(entered_name)
	print("Nama pemain tersimpan:", entered_name)
	
	current_state = State.NAME_SAVED
	
	# Transition from NameInputPanel to WoodPopUpPanel
	var tween_out = create_tween()
	tween_out.tween_property(name_input_panel, "modulate:a", 0.0, 0.2)
	tween_out.tween_callback(func(): name_input_panel.visible = false)
	
	wood_popup_panel.visible = true
	wood_popup_panel.scale = Vector2(0.7, 0.7)
	wood_popup_panel.modulate.a = 0.0
	
	var tween_in = create_tween().set_parallel(true)
	tween_in.tween_property(wood_popup_panel, "modulate:a", 1.0, 0.3)
	tween_in.tween_property(wood_popup_panel, "scale", Vector2.ONE, 0.4).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	
	_animate_button_text("Lanjut")

func _animate_button_text(new_text: String) -> void:
	var tween = create_tween()
	tween.tween_property(label_action, "modulate:a", 0.0, 0.1)
	tween.tween_callback(func(): 
		label_action.text = new_text
	)
	tween.tween_property(label_action, "modulate:a", 1.0, 0.15)

func _go_to_main_menu() -> void:
	var pd = get_node_or_null("/root/PlayerData")
	var p_name = pd.player_name if pd else "Arma"
	print("Membuka Main Menu untuk pemain:", p_name)
	get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")
