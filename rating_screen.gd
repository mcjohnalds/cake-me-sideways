@tool
class_name RatingScreen extends Control

@onready var _stars_fill: Label = $StarsFill
@onready var _layers: Control = $Layers


@export var layer_cooked_proportions: Array[float]:
	set(new):
		layer_cooked_proportions = new
		_update_ui()
	get:
		return layer_cooked_proportions


@export var layer_off_center_proportions: Array[float]:
	set(new):
		layer_off_center_proportions = new
		_update_ui()
	get:
		return layer_off_center_proportions


@export var layer_position_xs: Array[float]:
	set(new):
		layer_position_xs = new
		_update_ui()
	get:
		return layer_position_xs


func _ready() -> void:
	_update_ui()


func _update_ui() -> void:
	if not is_node_ready():
		return
	_update_stars_fill_ui()
	_update_layers_ui()


func _update_stars_fill_ui() -> void:
	var bake_score := _calculate_score_from_proportions(
		layer_cooked_proportions, Util.PERFECT_COOKED_PROPORTION
	)
	var stack_score := _calculate_score_from_proportions(
		# Skip bottom layer because it doesn't make sense for that layer to be
		# off-center
		layer_off_center_proportions.slice(1),
		0.0,
	)

	# star_count is between 0 and 5 (inclusive)
	var star_count := roundf((bake_score + stack_score) / 2.0 * 5.0)
	var stars_str := ""
	for i in star_count:
		stars_str += "★ "

	_stars_fill.text = stars_str


func _update_layers_ui() -> void:
	for layer_index in Util.MAX_LAYER_COUNT:
		var layer: Layer = _layers.get_child(layer_index)
		var is_layer_defined := (
			layer_index < layer_cooked_proportions.size()
			and layer_index < layer_position_xs.size()
		)
		if is_layer_defined:
			layer.visible = true
			layer.cooked_proportion = layer_cooked_proportions[layer_index]
			layer.position.x = layer_position_xs[layer_index]
		else:
			layer.visible = false


func _calculate_score_from_proportions(
	proportions: Array[float], perfect_proportion: float
) -> float:
	if proportions.size() == 0:
		return 0.0
	# scores[i] is 1.0 if proportions[i] == perfect_proportion, 0.0 if off by
	# more than 0.3
	var scores := proportions.map(
		func(p: float) -> float:
			return 1.0 - minf(absf(perfect_proportion - p) / 0.3, 1.0)
	)
	var sum: float = scores.reduce(
		func(acc: float, x: float) -> float:
			return acc + x
	)
	return sum / scores.size()
