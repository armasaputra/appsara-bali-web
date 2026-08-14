extends Control

@onready var character: TextureRect = $Character
@onready var button_mulai: TextureButton = $ButtonMulai
@onready var label_mulai: Label = $ButtonMulai/LabelMulai
@onready var title: TextureRect = $AksaraTitle

var initial_char_pos_y: float = 0.0

func _ready() -> void:
	initial_char_pos_y = character.position.y
	button_mulai.pressed.connect(_on_button_mulai_pressed)
	button_mulai.button_down.connect(_on_button_mulai_down)
	button_mulai.button_up.connect(_on_button_mulai_up)
	
	_start_idle_animation()

func _start_idle_animation() -> void:
	# Subtle breathing animation for the character
	var tween = create_tween().set_loops()
	tween.tween_property(character, "position:y", initial_char_pos_y - 10.0, 2.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(character, "position:y", initial_char_pos_y, 2.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

func _on_button_mulai_down() -> void:
	var tween = create_tween()
	tween.tween_property(button_mulai, "scale", Vector2(0.93, 0.93), 0.08).set_trans(Tween.TRANS_QUAD)

func _on_button_mulai_up() -> void:
	var tween = create_tween()
	tween.tween_property(button_mulai, "scale", Vector2(1.0, 1.0), 0.12).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

func _on_button_mulai_pressed() -> void:
	print("Tombol Mulai ditekan! Menuju aplikasi...")
