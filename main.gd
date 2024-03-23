extends Panel

const _PERFECT_COOKED_AMOUNT := 0.7
const _PERFECT_COOKED_THRESHOLD := 0.1
const _ORDER_LAYER_COUNT := 4
var _layer_cooked_amounts: Array[float] = []
var _thermometer_fill_ratio := 0.0
var _thermometer_is_raising := false
var _thermometer_is_paused := false


func _ready() -> void:
	$BakeButton.pressed.connect(_bake_button_pressed)


func _bake_button_pressed() -> void:
	if _thermometer_is_raising:
		_stop_thermometer()
	else:
		_thermometer_is_raising = true
		_thermometer_fill_ratio = 0.0


func _unhandled_input(event) -> void:
	if event is InputEventKey and event.pressed:
			if event.keycode == KEY_ESCAPE:
				get_tree().quit()


func _process(dt: float) -> void:
	if _thermometer_is_raising:
		_thermometer_fill_ratio += (0.3 + _thermometer_fill_ratio * 2.0) * dt
		if _thermometer_fill_ratio >= 1.0:
			_thermometer_fill_ratio = 1.0
			_stop_thermometer()
	_update_ui()


func _stop_thermometer() -> void:
	_thermometer_is_raising = false
	_thermometer_is_paused = true
	get_tree().create_timer(2.0).timeout.connect(func():
		_thermometer_is_paused = false
	)
	_layer_cooked_amounts.append(_thermometer_fill_ratio)


func _update_ui() -> void:
	$Pans/Panel1.visible = (
		_layer_cooked_amounts.size() < 1
	)
	$Pans/Panel2.visible = (
		_layer_cooked_amounts.size() < 2
	)
	$Pans/Panel3.visible = (
		_layer_cooked_amounts.size() < 3 and _ORDER_LAYER_COUNT > 2
	)
	$Pans/Panel4.visible = (
		_layer_cooked_amounts.size() < 4 and _ORDER_LAYER_COUNT > 3
	)
	for i in 4:
		_update_layer(i)
	_update_thermometer()
	var cooked_all_layers = (
		_layer_cooked_amounts.size() == _ORDER_LAYER_COUNT
	)
	$BakeButton.disabled = (
		_thermometer_is_paused
		or cooked_all_layers
	)
	$BakeButton.text = (
		"Stop!" if (
			_thermometer_is_raising
			or cooked_all_layers
			or _thermometer_is_paused
		)
		else "Bake!"
	)


func _update_layer(layer_index: int) -> void:
	if _layer_cooked_amounts.size() > layer_index:
		$Layers.get_child(layer_index).visible = true
		var style_box = (
			$Layers
				.get_child(layer_index)
				.get_node("OvercookedPanel")
				["theme_override_styles/panel"]
		)
		style_box.bg_color.a = _layer_cooked_amounts[layer_index] ** 2
	else:
		$Layers.get_child(layer_index).visible = false


func _update_thermometer() -> void:
	var thermo_h = $Thermometer.size.y
	var fill_h = _thermometer_fill_ratio * thermo_h
	var perfect_h = thermo_h * _PERFECT_COOKED_THRESHOLD
	$Thermometer/PerfectPanel.size.y = perfect_h
	$Thermometer/PerfectPanel.position.y = (
		(1.0 - _PERFECT_COOKED_AMOUNT) * thermo_h - perfect_h / 2.0
	)
	$Thermometer/FillPanel.size.y = fill_h
	$Thermometer/FillPanel.position.y = thermo_h - fill_h


func _time() -> float:
	return Time.get_ticks_msec() / 1000.0
