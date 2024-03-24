@tool
class_name MyButton extends TextureButton

@onready var _label: Label = $Label

@export var text: String = "":
	set(x):
		text = x
		_update_ui()
	get:
		return text


func _ready() -> void:
	button_down.connect(func() -> void: Autoload.button_down.play())
	button_up.connect(func() -> void: Autoload.button_up.play())
	_update_ui()


func _update_ui() -> void:
	if not is_node_ready():
		return
	_label.text = text
