extends Node

var player_name: String = "Arma"
var is_sound_muted: bool = false

func set_player_name(new_name: String) -> void:
	var trimmed = new_name.strip_edges()
	if not trimmed.is_empty():
		player_name = trimmed
	else:
		player_name = "Arma"

func set_sound_muted(muted: bool) -> void:
	is_sound_muted = muted
	var master_bus_idx = AudioServer.get_bus_index("Master")
	if master_bus_idx != -1:
		AudioServer.set_bus_mute(master_bus_idx, is_sound_muted)

