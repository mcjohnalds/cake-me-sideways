class_name BakeScreen extends Control

signal completed

const _PATH_PROGRESS_RATE := 2.0
const _PERFECT_COOKED_TOLERANCE := 0.1
var layer_count := 4
var layer_cooked_proportions: Array[float] = []
var _thermometer_fill_proportion := 0.0
var _thermometer_is_rising := false
@onready var _bake_button: BaseButton = $BakeButton
@onready var _bake_button_label: Label = $BakeButton/Label
@onready var _thermometer: Control = $Thermometer
@onready var _thermometer_fill: Control = $Thermometer/Fill
@onready var _thermometer_perfect: Panel = $Thermometer/Perfect
@onready var _rising_sound: AudioStreamPlayer = $RisingSound
@onready var _ding_sound: AudioStreamPlayer = $DingSound
@onready var _pans: Array[PathFollow2D] = [
	$Pans/Pan1Path/PathFollow2D,
	$Pans/Pan2Path/PathFollow2D,
	$Pans/Pan3Path/PathFollow2D,
	$Pans/Pan4Path/PathFollow2D,
]
@onready var _layer_path_follows: Array[PathFollow2D] = [
	$Layers/Layer1/PathFollow2D,
	$Layers/Layer2/PathFollow2D,
	$Layers/Layer3/PathFollow2D,
	$Layers/Layer4/PathFollow2D,
]
@onready var _layers: Array[Layer] = [
	$Layers/Layer1/PathFollow2D/Layer1,
	$Layers/Layer2/PathFollow2D/Layer2,
	$Layers/Layer3/PathFollow2D/Layer3,
	$Layers/Layer4/PathFollow2D/Layer4,
]


func _ready() -> void:
	_bake_button.pressed.connect(_bake_button_pressed)


func _bake_button_pressed() -> void:
	if _thermometer_is_rising:
		_stop_thermometer()
	else:
		_thermometer_is_rising = true
		_thermometer_fill_proportion = 0.0
		_rising_sound.play()


func _process(delta: float) -> void:
	if _thermometer_is_rising:
		_thermometer_fill_proportion += (
			(0.05 + _thermometer_fill_proportion * 5.0) * delta
		)
		if _thermometer_fill_proportion >= 1.0:
			_thermometer_fill_proportion = 1.0
			_stop_thermometer()
	
	var next_pan := _get_next_pan()
	if next_pan:
		next_pan.progress_ratio = minf(
			1.0,
			next_pan.progress_ratio + _PATH_PROGRESS_RATE * delta
		)

	if layer_cooked_proportions.size() > 0:
		var path_follow := (
			_layer_path_follows[layer_cooked_proportions.size() - 1]
		)
		path_follow.progress_ratio = maxf(
			0.0,
			path_follow.progress_ratio - _PATH_PROGRESS_RATE * delta
		)

	_update_ui()


func _stop_thermometer() -> void:
	_thermometer_is_rising = false
	layer_cooked_proportions.append(_thermometer_fill_proportion)
	_layers[layer_cooked_proportions.size() - 1].cooked_proportion = (
		_thermometer_fill_proportion
	)
	if layer_cooked_proportions.size() == layer_count:
		get_tree().create_timer(1.0).timeout.connect(func() -> void:
			completed.emit()
		)
	_rising_sound.stop()
	_ding_sound.play()


func _update_ui() -> void:
	for i in Util.MAX_LAYER_COUNT:
		var layer_is_in_order := i < layer_count
		var layer_is_cooked := i < layer_cooked_proportions.size()
		_pans[i].visible = (
			layer_is_in_order and not layer_is_cooked
		)
		_layers[i].visible = layer_is_cooked
	_update_thermometer()
	var cooked_all_layers := (
		layer_cooked_proportions.size() == layer_count
	)
	var next_pan_is_moving := (
		_get_next_pan().progress_ratio < 1.0 if _get_next_pan() else false
	)
	_bake_button.disabled = (
		next_pan_is_moving
		or cooked_all_layers
	)
	_bake_button_label.text = (
		"STOP" if _thermometer_is_rising or next_pan_is_moving
		else "START"
	)


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


func _get_next_pan() -> PathFollow2D:
	if layer_cooked_proportions.size() < layer_count:
		return _pans[layer_cooked_proportions.size()]
	else:
		return null
