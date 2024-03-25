extends Node

@onready var button_down: AudioStreamPlayer = $Down
@onready var button_up: AudioStreamPlayer = $Up
@onready var play_music: AudioStreamPlayer = $PlayMusic
@onready var end_music: AudioStreamPlayer = $EndMusic


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey:
		var k := event as InputEventKey
		if k.pressed and k.keycode == KEY_ESCAPE:
			get_tree().quit()
