class_name Main extends Control

@onready var _bake_screen: BakeScreen = $BakeScreen
@onready var _active_screen: Control = _bake_screen


func _ready() -> void:
	_bake_screen.completed.connect(_on_bake_screen_completed)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey:
		var k := event as InputEventKey
		if k.pressed and k.keycode == KEY_ESCAPE:
			get_tree().quit()


func _process(_delta: float) -> void:
	_update_ui()


func _on_bake_screen_completed() -> void:
	_active_screen = null


func _update_ui() -> void:
	_bake_screen.visible = _active_screen == _bake_screen
