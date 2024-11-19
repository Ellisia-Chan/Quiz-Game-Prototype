extends Control

@export_category("Labels")
@export var score_label: Label

@export_category("Buttons")
@export var retry_button: Button
@export var main_menu_button: Button

var quiz_ui_script

func _ready() -> void:
	quiz_ui_script = get_node("../MainQuizUI")
	quiz_ui_script.connect("on_quiz_finish", Callable(self, "_on_quiz_finish"))

	retry_button.connect("pressed", Callable(self, "_on_retry_button_pressed"))
	hide()

func _on_retry_button_pressed() -> void:
	get_tree().reload_current_scene()
	print("Retry button pressed")

func _on_quiz_finish() -> void:
	score_label.text = "Score: " + str(quiz_ui_script.score)
	show()
