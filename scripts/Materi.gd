extends Control

@onready var btn_kembali: TextureButton = $BtnKembali
@onready var scroll_container: ScrollContainer = $ScrollContainer
@onready var list_container: VBoxContainer = $ScrollContainer/ListContainer

# Drag-to-scroll state
var _is_dragging: bool = false
var _is_pointer_down: bool = false
var _drag_start_y: float = 0.0
var _last_drag_y: float = 0.0
var _exact_scroll_y: float = 0.0
var _scroll_velocity: float = 0.0
var _drag_threshold: float = 14.0
var _active_button: TextureButton = null
var _active_callback: Callable = Callable()
var _last_touch_time: int = 0

func _ready() -> void:
	# Hide default scrollbar track for clean UI look
	if scroll_container:
		var v_scroll = scroll_container.get_v_scroll_bar()
		if v_scroll:
			v_scroll.modulate.a = 0.0
		scroll_container.gui_input.connect(_on_scroll_gui_input)
	
	# Setup Kembali button
	_setup_static_button(btn_kembali, _on_kembali_pressed)
	
	# Setup all list buttons with drag-to-scroll support
	for child in list_container.get_children():
		if child is TextureButton:
			var btn_index = child.get_index() + 1
			_setup_draggable_button(child, func(): _on_materi_item_pressed(btn_index))

func _get_max_scroll() -> float:
	if not scroll_container:
		return 0.0
	var v_bar = scroll_container.get_v_scroll_bar()
	if v_bar:
		return maxf(0.0, v_bar.max_value - v_bar.page)
	return 2000.0

func _process(delta: float) -> void:
	if not _is_pointer_down and abs(_scroll_velocity) > 10.0 and scroll_container:
		_exact_scroll_y = clampf(_exact_scroll_y + _scroll_velocity * delta, 0.0, _get_max_scroll())
		scroll_container.scroll_vertical = int(round(_exact_scroll_y))
		_scroll_velocity = lerp(_scroll_velocity, 0.0, 7.0 * delta)
		if _exact_scroll_y <= 0.0 or _exact_scroll_y >= _get_max_scroll():
			_scroll_velocity = 0.0
	elif not _is_pointer_down:
		_scroll_velocity = 0.0

func _setup_static_button(btn: TextureButton, callback: Callable) -> void:
	if not btn:
		return
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

func _setup_draggable_button(btn: TextureButton, callback: Callable) -> void:
	btn.mouse_entered.connect(func():
		if not _is_dragging and not _is_pointer_down:
			var tween = create_tween()
			tween.tween_property(btn, "scale", Vector2(1.025, 1.025), 0.15).set_trans(Tween.TRANS_SINE)
	)
	btn.mouse_exited.connect(func():
		var tween = create_tween()
		tween.tween_property(btn, "scale", Vector2(1.0, 1.0), 0.15).set_trans(Tween.TRANS_SINE)
	)
	btn.gui_input.connect(func(event: InputEvent):
		_handle_drag_input(event, btn, callback)
	)

func _on_scroll_gui_input(event: InputEvent) -> void:
	_handle_drag_input(event, null, Callable())

func _handle_drag_input(event: InputEvent, btn: TextureButton, callback: Callable) -> void:
	var now = Time.get_ticks_msec()
	
	# 1. Touch Events (Mobile Touchscreen)
	if event is InputEventScreenTouch:
		_last_touch_time = now
		if event.pressed:
			_is_pointer_down = true
			_is_dragging = false
			_drag_start_y = event.position.y
			_last_drag_y = event.position.y
			_exact_scroll_y = float(scroll_container.scroll_vertical) if scroll_container else 0.0
			_scroll_velocity = 0.0
			_active_button = btn
			_active_callback = callback
			if btn:
				var tween = create_tween()
				tween.tween_property(btn, "scale", Vector2(0.95, 0.95), 0.08).set_trans(Tween.TRANS_QUAD)
		else:
			_on_pointer_release()
			
	elif event is InputEventScreenDrag:
		_last_touch_time = now
		if _is_pointer_down:
			var current_y = event.position.y
			var total_delta = current_y - _drag_start_y
			
			if not _is_dragging and abs(total_delta) > _drag_threshold:
				_is_dragging = true
				if _active_button:
					var tween = create_tween()
					tween.tween_property(_active_button, "scale", Vector2.ONE, 0.1)
					
			if _is_dragging and scroll_container:
				var delta_y = current_y - _last_drag_y
				_exact_scroll_y = clampf(_exact_scroll_y - delta_y, 0.0, _get_max_scroll())
				scroll_container.scroll_vertical = int(round(_exact_scroll_y))
				_scroll_velocity = lerp(_scroll_velocity, -delta_y * 50.0, 0.35)
				_last_drag_y = current_y

	# 2. Mouse Events (Desktop only - ignore emulated events within 250ms of touch)
	elif event is InputEventMouseButton:
		if now - _last_touch_time < 250:
			return
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				_is_pointer_down = true
				_is_dragging = false
				_drag_start_y = event.global_position.y
				_last_drag_y = event.global_position.y
				_exact_scroll_y = float(scroll_container.scroll_vertical) if scroll_container else 0.0
				_scroll_velocity = 0.0
				_active_button = btn
				_active_callback = callback
				if btn:
					var tween = create_tween()
					tween.tween_property(btn, "scale", Vector2(0.95, 0.95), 0.08).set_trans(Tween.TRANS_QUAD)
			else:
				_on_pointer_release()

	elif event is InputEventMouseMotion:
		if now - _last_touch_time < 250:
			return
		if _is_pointer_down:
			var current_y = event.global_position.y
			var total_delta = current_y - _drag_start_y
			
			if not _is_dragging and abs(total_delta) > _drag_threshold:
				_is_dragging = true
				if _active_button:
					var tween = create_tween()
					tween.tween_property(_active_button, "scale", Vector2.ONE, 0.1)
					
			if _is_dragging and scroll_container:
				var delta_y = current_y - _last_drag_y
				_exact_scroll_y = clampf(_exact_scroll_y - delta_y, 0.0, _get_max_scroll())
				scroll_container.scroll_vertical = int(round(_exact_scroll_y))
				_scroll_velocity = lerp(_scroll_velocity, -delta_y * 50.0, 0.35)
				_last_drag_y = current_y

func _on_pointer_release() -> void:
	if not _is_pointer_down:
		return
	_is_pointer_down = false
	var was_dragging = _is_dragging
	var target_btn = _active_button
	var target_cb = _active_callback
	
	if target_btn:
		var tween = create_tween()
		tween.tween_property(target_btn, "scale", Vector2.ONE, 0.12).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	
	_is_dragging = false
	_active_button = null
	_active_callback = Callable()
	
	if not was_dragging and target_cb.is_valid():
		var am = get_node_or_null("/root/AudioManager")
		if am and am.has_method("play_click"):
			am.play_click()
		target_cb.call()

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and not event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if _is_pointer_down and _is_dragging:
			_on_pointer_release()

func _on_materi_item_pressed(index: int) -> void:
	print("Materi %d dipilih!" % index)
	var pd = get_node_or_null("/root/PlayerData")
	if pd:
		pd.is_gameplay_mode = false
		pd.from_latihan_retry = false
		if pd.has_method("set_current_materi"):
			pd.set_current_materi(index)
	get_tree().change_scene_to_file("res://scenes/Isimateri.tscn")

func _on_kembali_pressed() -> void:
	print("Kembali ke Main Menu...")
	get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")



