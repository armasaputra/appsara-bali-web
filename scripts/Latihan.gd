extends Control

@onready var btn_kembali: TextureButton = $BtnKembali
@onready var scroll_container: ScrollContainer = $ScrollContainer
@onready var list_container: VBoxContainer = $ScrollContainer/ListContainer

func _ready() -> void:
	# Hide default scrollbar track for clean UI look
	if scroll_container:
		var v_scroll = scroll_container.get_v_scroll_bar()
		if v_scroll:
			v_scroll.modulate.a = 0.0
	
	# Setup Kembali button
	_setup_button(btn_kembali, _on_kembali_pressed)
	
	# Setup all list buttons
	for child in list_container.get_children():
		if child is TextureButton:
			var btn_index = child.get_index() + 1
			_setup_button(child, func(): _on_latihan_item_pressed(btn_index))

func _setup_button(btn: TextureButton, callback: Callable) -> void:
	btn.pressed.connect(callback)
	btn.button_down.connect(func():
		var tween = create_tween()
		tween.tween_property(btn, "scale", Vector2(0.95, 0.95), 0.08).set_trans(Tween.TRANS_QUAD)
	)
	btn.button_up.connect(func():
		var tween = create_tween()
		tween.tween_property(btn, "scale", Vector2(1.0, 1.0), 0.12).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	)
	btn.mouse_entered.connect(func():
		var tween = create_tween()
		tween.tween_property(btn, "scale", Vector2(1.025, 1.025), 0.15).set_trans(Tween.TRANS_SINE)
	)
	btn.mouse_exited.connect(func():
		var tween = create_tween()
		tween.tween_property(btn, "scale", Vector2(1.0, 1.0), 0.15).set_trans(Tween.TRANS_SINE)
	)

func _on_latihan_item_pressed(index: int) -> void:
	print("Latihan %d dipilih!" % index)

func _on_kembali_pressed() -> void:
	print("Kembali ke Main Menu...")
	get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")
