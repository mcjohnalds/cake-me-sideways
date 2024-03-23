class_name Main extends Control

const _orders_screen_scene := preload("res://orders_screen.tscn")
const _bake_screen_scene := preload("res://bake_screen.tscn")
const _stack_screen_scene := preload("res://stack_screen.tscn")
const _rating_screen_scene := preload("res://rating_screen.tscn")
var _orders_screen: OrdersScreen
var _bake_screen: BakeScreen
var _stack_screen: StackScreen
var _rating_screen: RatingScreen
var _reward: int
@onready var _screen_title: Label = $ScreenTitle
@onready var _money_label: Label = $MoneyLabel


var _money: int:
	set(new_money):
		_money = new_money
		_money_label.text = "$%s" % new_money
	get:
		return _money


func _ready() -> void:
	_money = 0
	_go_to_orders_screen()


func _go_to_orders_screen() -> void:
	_screen_title.text = "Orders"
	_orders_screen = _orders_screen_scene.instantiate()
	_orders_screen.order_accepted.connect(_on_order_accepted)
	add_child(_orders_screen)


func _on_order_accepted(layer_count: int, reward: int) -> void:
	_reward = reward
	_orders_screen.queue_free()
	_screen_title.text = "Bake"
	_bake_screen = _bake_screen_scene.instantiate()
	_bake_screen.layer_count = layer_count
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
	_rating_screen = _rating_screen_scene.instantiate()
	_rating_screen.reward = _reward
	_rating_screen.layer_position_xs = (
		_stack_screen.get_layer_position_xs()
	)
	_rating_screen.layer_cooked_proportions = (
		_stack_screen.layer_cooked_proportions
	)
	_rating_screen.layer_off_center_proportions = (
		_stack_screen.get_layer_off_center_proportions()
	)
	_rating_screen.completed.connect(_on_rating_screen_completed)
	add_child(_rating_screen)


func _on_rating_screen_completed() -> void:
	_rating_screen.queue_free()
	_money += _reward + _rating_screen.get_star_bonus()
	_go_to_orders_screen()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey:
		var k := event as InputEventKey
		if k.pressed and k.keycode == KEY_ESCAPE:
			get_tree().quit()
