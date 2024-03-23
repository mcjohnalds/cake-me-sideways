class_name Main extends Control

const _rating_screen := preload("res://rating_screen.tscn")
const _bake_screen_scene := preload("res://bake_screen.tscn")
const _stack_screen_scene := preload("res://stack_screen.tscn")
var _bake_screen: BakeScreen
var _stack_screen: StackScreen
@onready var _screen_title: Label = $ScreenTitle


func _ready() -> void:
	_bake_screen = _bake_screen_scene.instantiate()
	_bake_screen.completed.connect(_on_bake_screen_completed)
	add_child(_bake_screen)


func _on_bake_screen_completed() -> void:
	_bake_screen.queue_free()
	_screen_title.text = "Stack"
	_stack_screen = _stack_screen_scene.instantiate()
	_stack_screen.layer_cooked_proportions = (
		_bake_screen.layer_cooked_proportions
	)
	_stack_screen.completed.connect(_on_stack_screen_completed)
	add_child(_stack_screen)


func _on_stack_screen_completed() -> void:
	_stack_screen.queue_free()
	_screen_title.text = "Rating"
	var rating_screen: RatingScreen = _rating_screen.instantiate()
	add_child(rating_screen)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey:
		var k := event as InputEventKey
		if k.pressed and k.keycode == KEY_ESCAPE:
			get_tree().quit()
