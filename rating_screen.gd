@tool
class_name RatingScreen extends Control

signal completed

var reward: int
@onready var _stars_fill: Label = $StarsFill
@onready var _reward_label: Label = $RewardLabel
@onready var _star_bonus_label: Label = $StarBonusLabel
@onready var _total_label: Label = $TotalLabel
@onready var _layers: Control = $Layers
@onready var _ok_button: Button = $OkButton


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


func get_star_bonus() -> int:
	return roundi(float(reward) * (float(_get_star_score()) ** 2.0))


func _ready() -> void:
	_ok_button.pressed.connect(func() -> void: completed.emit())
	_update_ui()


func _update_ui() -> void:
	if not is_node_ready():
		return

	var star_score := _get_star_score()
	var star_count := roundi(star_score * 5.0)
	var stars_str := ""
	for i in star_count:
		stars_str += "★ "
	_stars_fill.text = stars_str

	_reward_label.text = "$%s" % reward

	var star_bonus := get_star_bonus()
	_star_bonus_label.text = "$%s" % star_bonus

	_total_label.text = "$%s" % (reward + star_bonus)

	_update_layers_ui()


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


# star_score is between 0.0 and 1.0 (inclusive)
func _get_star_score() -> float:
	var bake_score := _calculate_score_from_proportions(
		layer_cooked_proportions, Util.PERFECT_COOKED_PROPORTION
	)
	var stack_score := _calculate_score_from_proportions(
		# Skip bottom layer because it doesn't make sense for that layer to be
		# off-center
		layer_off_center_proportions.slice(1),
		0.0,
	)
	return (bake_score + stack_score) / 2.0


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
