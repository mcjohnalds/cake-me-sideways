class_name BakeScreen extends Control

signal completed

const _PERFECT_COOKED_TOLERANCE := 0.1
var layer_count: int
var layer_cooked_proportions: Array[float]
var _thermometer_fill_proportion := 0.0
var _thermometer_is_raising := false
var _thermometer_is_paused := false
@onready var _pans_control: Control = $Pans
@onready var _layers_control: Control = $Layers
@onready var _bake_button: BaseButton = $BakeButton
@onready var _bake_button_label: Label = $BakeButton/Label
@onready var _thermometer: Control = $Thermometer
@onready var _thermometer_fill: Control = $Thermometer/Fill
@onready var _thermometer_perfect: Panel = $Thermometer/Perfect

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
		if layer_cooked_proportions.size() == layer_count:
			completed.emit()
	)
	layer_cooked_proportions.append(_thermometer_fill_proportion)


func _update_ui() -> void:
	for i in Util.MAX_LAYER_COUNT:
		var pan: Control = _pans_control.get_child(i)
		var layer_is_in_order := i < layer_count
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
		layer_cooked_proportions.size() == layer_count
	)
	_bake_button.disabled = (
		_thermometer_is_paused
		or cooked_all_layers
	)
	_bake_button_label.text = (
		"STOP" if _thermometer_is_raising or _thermometer_is_paused
		else "START"
	)


func _update_layer(layer_index: int) -> void:
	var layer: Layer = _layers_control.get_child(layer_index)
	if layer_cooked_proportions.size() > layer_index:
		layer.visible = true
		layer.cooked_proportion = layer_cooked_proportions[layer_index]
	else:
		layer.visible = false


func _update_thermometer() -> void:
	var thermo_h := _thermometer.size.y
	# `_thermometer_fill` has `fill_padding` pixels of padding at the bottom of
	# its image so calculations need to be offset by this amount
	var fill_padding := 14.0 
	var fill_h := _thermometer_fill_proportion * thermo_h + fill_padding
	_thermometer_perfect.position.y = (
		(1.0 - Util.PERFECT_COOKED_PROPORTION) * thermo_h
		- fill_padding
		- _thermometer_perfect.size.y / 2.0
	)
	_thermometer_fill.size.y = fill_h
	_thermometer_fill.position.y = thermo_h - fill_h
