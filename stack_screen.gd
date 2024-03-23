class_name StackScreen extends Control

signal completed

const _layer_scene := preload("res://layer.tscn")
var layer_cooked_proportions: Array[float]
var _layers: Array[Layer] = []
var _layer_movement_direction := 1.0
var _is_complete := false
@onready var _drop_zone: Control = $DropZone
@onready var _drop_button: Button = $DropButton

# Returns array arr where arr[i] is the distance from the top-left x coordinate
# of layer i from the top-left coordinate of layer i-1.
func get_layer_position_xs() -> Array[float]:
	var arr: Array[float] = []
	for i in _layers.size():
		arr.append(_layers[i].position.x - _layers[0].position.x)
	return arr

# Returns array arr where arr[i] is 0.0 if layer 1 was perfectly centered, 1.0
# if layer was far off-center.
func get_layer_off_center_proportions() -> Array[float]:
	var arr: Array[float] = []
	for i in _layers.size():
		arr.append(_get_layer_off_center_proportion(i))
	return arr


func _ready() -> void:
	_drop_button.pressed.connect(_on_drop_button_pressed)
	var layer: Layer = _layer_scene.instantiate()
	layer.layer_index = 0
	layer.cooked_proportion = layer_cooked_proportions[0]
	_drop_zone.add_child(layer)
	_layers.append(layer)


func _process(delta: float) -> void:
	if not _is_complete:
		_move_top_layer_side_to_side(delta)
	_update_ui()


func _on_drop_button_pressed() -> void:
	if _layers.size() == 1:
		_layers[-1].position.y = _drop_zone.size.y - _layers[-1].size.y
	else:
		_layers[-1].position.y = _layers[-2].position.y - _layers[-1].size.y

	if _layers.size() < layer_cooked_proportions.size():
		var new_layer: Layer = _layer_scene.instantiate()
		new_layer.layer_index = _layers.size()
		new_layer.cooked_proportion = layer_cooked_proportions[_layers.size()]
		_drop_zone.add_child(new_layer)
		_layers.append(new_layer)
	else:
		_is_complete = true
		get_tree().create_timer(1.0).timeout.connect(func() -> void:
			completed.emit()
		)


func _move_top_layer_side_to_side(delta: float) -> void:
	var top_layer := _layers[-1]

	var min_x: float
	var max_x: float
	var half_sx := top_layer.size.x / 2.0
	if _layers.size() == 1:
		min_x = half_sx
		max_x = _drop_zone.size.x - top_layer.size.x - half_sx
	else:
		var previous_layer := _layers[-2]
		min_x = previous_layer.position.x - half_sx
		max_x = (
			previous_layer.position.x
			+ previous_layer.size.x
			- top_layer.size.x
			+ half_sx
		)

	var off_center_factor := _get_layer_off_center_proportion(-1)
	top_layer.position.x += (
		(100.0 + (1.0 - off_center_factor) * 200.0)
		* delta
		* _layer_movement_direction
	)

	var is_outside_bounds := (
		top_layer.position.x < min_x or top_layer.position.x > max_x
	)
	if is_outside_bounds:
		top_layer.position.x = clampf(top_layer.position.x, min_x, max_x)
		_layer_movement_direction *= -1.0


func _get_layer_off_center_proportion(layer_index: int) -> float:
	var layer := _layers[layer_index]
	var layer_center_x := layer.position.x + layer.size.x / 2.0

	if _layers.size() == 1:
		var distance_to_center := _drop_zone.size.x / 2.0 - layer_center_x
		return absf(distance_to_center / (_drop_zone.size.x / 2.0))
	else:
		var previous_layer := _layers[layer_index - 1]
		var previous_layer_center_x := (
			previous_layer.position.x
			+ previous_layer.size.x / 2.0
		)
		var distance_to_center := previous_layer_center_x - layer_center_x
		return (
			absf(distance_to_center / (previous_layer.size.x / 2.0))
		)


func _update_ui() -> void:
	_drop_button.disabled = _is_complete
