class_name EndScreen extends Control

signal completed

@onready var _final_score_label: Label = $Card/FinalScoreLabel
@onready var _ok_button: BaseButton = $OkButton
@onready var _end_sound: AudioStreamPlayer = $EndSound


var final_score: int:
	set(new):
		final_score = new
		_final_score_label.text = "$%s" % final_score


func _ready() -> void:
	_end_sound.play()
	_ok_button.pressed.connect(_on_ok_button_presssed)
	get_tree().create_timer(4.0).timeout.connect(func() -> void:
		_ok_button.disabled = false
	)
	Autoload.play_music.stop()  
	Autoload.end_music.play()


func _on_ok_button_presssed() -> void:
	completed.emit()
	Autoload.end_music.stop()
	Autoload.play_music.play()
