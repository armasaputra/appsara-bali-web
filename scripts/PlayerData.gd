extends Node

var player_name: String = "Arma"
var is_sound_muted: bool = false

var current_materi_index: int = 1
var current_latihan_index: int = 1

# Latihan retry & back flow state
var from_latihan_retry: bool = false
var latihan_return_question_idx: int = 0

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

func set_current_materi(index: int) -> void:
	current_materi_index = index

func set_current_latihan(index: int) -> void:
	current_latihan_index = index
