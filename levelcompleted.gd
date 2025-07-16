extends ColorRect

signal retry()
signal next_level()
@onready var retry_button: Button = %RetryButton
@onready var next_level_button: Button = %NextLevelbutton


	
func _on_next_levelbutton_pressed() -> void:
	next_level.emit()

func _on_retry_button_pressed() -> void:
	retry.emit()
