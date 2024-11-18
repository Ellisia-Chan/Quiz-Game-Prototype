extends Node

signal on_question_show
signal on_answer_action

@export_category("Labels")
@export var question_label: Label
@export var timer_label: Label
@export var question_number_label: Label
@export var score_label: Label

@export_category("Buttons")
@export var button_group: Array[Button] = []
@export var next_question_button: Button

@onready var timer: Timer = $Timer

var question = []
var current_question_index: int = 0
var timer_value: int = 0
var correct_answer_index: int = 0
var max_question: int = 5
var score: int = 0

func _ready() -> void:
	load_questions()
	show_question(current_question_index)

	# Connect button press events for each answer button
	for button in button_group:
		button.connect("pressed", Callable(self, "_on_choice_pressed").bind(button_group.find(button)))
	
	# Connect the "Next Question" button
	next_question_button.connect("pressed", Callable(self, "show_next_question"))
	next_question_button.hide()

func load_questions() -> void:
	# Load and parse the questions from a JSON file
	var file = FileAccess.open("res://Questions/Questions.json", FileAccess.READ)

	if file:
		question = JSON.parse_string(file.get_as_text())
		file.close()
		question.shuffle()
	else:
		print("Failed to open file or file does not exist")

func show_question(index: int) -> void:
	var question_data = question[index]
	question_label.text = question_data["question"]
	timer_value = question_data["time"]
	correct_answer_index = question_data["answer"]

	question_number_label.text = "Question " + str(index + 1) + " / " + str(max_question)
	update_timer_display()

	# Shuffle and assign choices to buttons
	var choices = question_data["choices"].duplicate()
	var correct_answer = choices[correct_answer_index]
	choices.shuffle()
	correct_answer_index = choices.find(correct_answer)

	for i in range(button_group.size()):
		var button = button_group[i]
		button.modulate = Color(1, 1, 1) # Reset appearance
		button.mouse_filter = Control.MOUSE_FILTER_PASS
		button.text = choices[i]

	on_question_show.emit()
	timer.start()

func _on_choice_pressed(choice_index: int) -> void:
	on_answer_action.emit()
	timer.stop()

	var is_correct = (choice_index == correct_answer_index)
	if is_correct:
		score += 1
	
	score_label.text = "Score: " + str(score)
	show_feedback(is_correct, choice_index)
	
	if current_question_index == max_question - 1:
		next_question_button.text = "Finish"

	next_question_button.show()

func show_next_question() -> void:
	if current_question_index + 1 < max_question and current_question_index + 1 < question.size():
		current_question_index += 1
		next_question_button.hide()
		show_question(current_question_index)
	else:
		print("Game over! Final score: ", score)

func update_timer_display() -> void:
	timer_label.text = str(timer_value)

func _on_timer_timeout() -> void:
	timer_value -= 1
	update_timer_display()

	if timer_value <= 0:
		timer.stop()
		print("Time's up!")
		disable_buttons()
		show_feedback(false, correct_answer_index)
		next_question_button.show()

func show_feedback(is_correct: bool, choice_index: int) -> void:
	# Disable all buttons and highlight the selected answer
	disable_buttons()

	button_group[choice_index].modulate = Color(0, 1, 0) if is_correct else Color(1, 0, 0)
	button_group[correct_answer_index].modulate = Color(0, 1, 0) # Highlight the correct answer

func disable_buttons() -> void:
	for button in button_group:
		button.mouse_filter = Control.MOUSE_FILTER_IGNORE
