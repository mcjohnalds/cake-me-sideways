class_name Main extends Control

const _bake_screen_scene := preload("res://bake_screen.tscn")
const _stack_screen_scene := preload("res://stack_screen.tscn")
@onready var _screen_title: Label = $ScreenTitle


func _ready() -> void:
	var bake_screen: BakeScreen = _bake_screen_scene.instantiate()
	bake_screen.completed.connect(func() -> void:
		bake_screen.queue_free()
		_screen_title.text = "Stack"
		var stack_screen: StackScreen = _stack_screen_scene.instantiate()
		stack_screen.layer_cooked_amounts = bake_screen.layer_cooked_amounts
		add_child(stack_screen)
	)
	add_child(bake_screen)

	#_screen_title.text = "Stack"
	#var stack_screen: StackScreen = _stack_screen_scene.instantiate()
	#stack_screen.layer_cooked_amounts = [0.1, 0.5, 0.8]
	#add_child(stack_screen)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey:
		var k := event as InputEventKey
		if k.pressed and k.keycode == KEY_ESCAPE:
			get_tree().quit()
