extends Panel


func _unhandled_input(event):
	if event is InputEventKey and event.pressed:
			if event.keycode == KEY_ESCAPE:
				get_tree().quit()
			if event.keycode == KEY_SPACE:
				$Panel.position.x += 10.0;
