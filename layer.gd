@tool
class_name Layer extends Control

const _UNDERCOOKED_COLOR := Color("#fff1e6")
const _OVERCOOKED_COLOR := Color("#4d3522")
const _PERFECT_COLOR := Color("#faca82")

@export_range(0, Util.MAX_LAYER_COUNT - 1) var layer_index := 0:
	set(new_layer_index):
		layer_index = new_layer_index
		_update_ui()

@export_range(0.0, 1.0, 0.1) var cooked_proportion := 0.0:
	set(p):
		cooked_proportion = p
		_update_ui()

@onready var _texture_rect: TextureRect = $TextureRect


func _ready() -> void:
	_update_ui()


func _update_ui() -> void:
	if not is_node_ready():
		return

	size.x = 120.0 - 20.0 * layer_index
	
	var p := cooked_proportion
	if p < Util.PERFECT_COOKED_PROPORTION:
		_texture_rect.modulate = _UNDERCOOKED_COLOR.lerp(
			_PERFECT_COLOR,
			(p / Util.PERFECT_COOKED_PROPORTION) ** 4.0
		)
	else:
		_texture_rect.modulate = _OVERCOOKED_COLOR.lerp(
			_PERFECT_COLOR,
			(1 - ((p - Util.PERFECT_COOKED_PROPORTION) / (1.0 - Util.PERFECT_COOKED_PROPORTION))) ** 2.0
		)
