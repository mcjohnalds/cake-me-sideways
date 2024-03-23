class_name EndScreen extends Control

signal completed

@onready var _final_score_label: Label = $FinalScoreLabel
@onready var _ok_button: Button = $OkButton


var final_score: int:
	set(new):
		final_score = new
		_final_score_label.text = "$%s" % final_score


func _ready() -> void:
	_ok_button.pressed.connect(func() -> void: completed.emit())
