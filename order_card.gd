@tool
class_name OrderCard extends Panel

signal accepted

@onready var _layers_label: Label
@onready var _reward_label: Label


@export_range(0, Util.MAX_LAYER_COUNT) var layer_count: int = 0:
	set(new):
		layer_count = new
		_update_ui()
	get:
		return layer_count


@export_range(0, 500, 50) var reward: int = 0:
	set(new):
		reward = new
		_update_ui()
	get:
		return reward


func _ready() -> void:
	_layers_label = $LayersLabel
	_reward_label = $RewardLabel
	var accept_button: Button = $AcceptButton
	accept_button.pressed.connect(func() -> void: accepted.emit())
	_update_ui()


func _update_ui() -> void:
	if not is_node_ready():
		return
	_layers_label.text = "%s" % layer_count
	_reward_label.text = "$%s" % reward
