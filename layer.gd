@tool
class_name Layer extends Control

@export_range(0, Util.MAX_LAYER_COUNT - 1) var layer_index := 0:
	set(new_layer_index):
		layer_index = new_layer_index
		size.x = 120.0 - 20.0 * layer_index

@export_range(0.0, 1.0, 0.1) var cooked_proportion := 0.0:
	set(new_cooked_proportion):
		cooked_proportion = new_cooked_proportion
		_box.bg_color.a = new_cooked_proportion

var _box := StyleBoxFlat.new()
@onready var _undercooked_panel: Panel = $UndercookedPanel

func _ready() -> void:
	_undercooked_panel.remove_theme_stylebox_override("panel")
	_undercooked_panel.add_theme_stylebox_override("panel", _box)
