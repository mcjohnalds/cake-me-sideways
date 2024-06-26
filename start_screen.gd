class_name StartScreen extends Control

signal start_button_pressed

@onready var _start_button: MyButton = $StartButton


func _ready() -> void:
	_start_button.pressed.connect(func() -> void:
		start_button_pressed.emit()
	)
