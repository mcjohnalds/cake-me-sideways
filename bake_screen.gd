class_name BakeScreen extends Control

signal completed

const _PERFECT_COOKED_TOLERANCE := 0.1
const _ORDER_LAYER_COUNT := 2
var layer_cooked_proportions: Array[float]
var _thermometer_fill_proportion := 0.0
var _thermometer_is_raising := false
var _thermometer_is_paused := false
@onready var _pans_control: Control = $Pans
@onready var _layers_control: Control = $Layers
@onready var _bake_button: Button = $BakeButton
@onready var _thermometer: Control = $Thermometer
@onready var _thermometer_fill_panel: Panel = $Thermometer/FillPanel
@onready var _thermometer_perfect_panel: Panel = $Thermometer/PerfectPanel

func _ready() -> void:
	_bake_button.pressed.connect(_bake_button_pressed)


func _bake_button_pressed() -> void:
	if _thermometer_is_raising:
		_stop_thermometer()
	else:
		_thermometer_is_raising = true
		_thermometer_fill_proportion = 0.0


func _process(delta: float) -> void:
	if _thermometer_is_raising:
		_thermometer_fill_proportion += (
			(0.05 + _thermometer_fill_proportion * 5.0) * delta
		)
		if _thermometer_fill_proportion >= 1.0:
			_thermometer_fill_proportion = 1.0
			_stop_thermometer()
	_update_ui()


func _stop_thermometer() -> void:
	_thermometer_is_raising = false
	_thermometer_is_paused = true
	get_tree().create_timer(1.0).timeout.connect(func() -> void:
		_thermometer_is_paused = false
		if layer_cooked_proportions.size() == _ORDER_LAYER_COUNT:
			completed.emit()
	)
	layer_cooked_proportions.append(_thermometer_fill_proportion)


func _update_ui() -> void:
	for i in Util.MAX_LAYER_COUNT:
		var pan := _pans_control.get_child(i) as Panel
		var layer_is_in_order := i < _ORDER_LAYER_COUNT
		var layer_is_cooked := i < layer_cooked_proportions.size()
		var layer_is_cooking := (
			_thermometer_is_raising and i == layer_cooked_proportions.size()
		)
		pan.visible = (
			layer_is_in_order and not layer_is_cooked and not layer_is_cooking
		)
	for i in Util.MAX_LAYER_COUNT:
		_update_layer(i)
	_update_thermometer()
	var cooked_all_layers := (
		layer_cooked_proportions.size() == _ORDER_LAYER_COUNT
	)
	_bake_button.disabled = (
		_thermometer_is_paused
		or cooked_all_layers
	)
	_bake_button.text = (
		"Stop!" if _thermometer_is_raising or _thermometer_is_paused
		else "Bake!"
	)


func _update_layer(layer_index: int) -> void:
	var layer: Layer = _layers_control.get_child(layer_index)
	if layer_cooked_proportions.size() > layer_index:
		layer.visible = true
		layer.cooked_proportion = layer_cooked_proportions[layer_index] ** 2.0
	else:
		layer.visible = false


func _update_thermometer() -> void:
	var thermo_h := _thermometer.size.y
	var fill_h := _thermometer_fill_proportion * thermo_h
	var perfect_h := thermo_h * _PERFECT_COOKED_TOLERANCE
	_thermometer_perfect_panel.size.y = perfect_h
	_thermometer_perfect_panel.position.y = (
		(1.0 - Util.PERFECT_COOKED_PROPORTION) * thermo_h - perfect_h / 2.0
	)
	_thermometer_fill_panel.size.y = fill_h
	_thermometer_fill_panel.position.y = thermo_h - fill_h
