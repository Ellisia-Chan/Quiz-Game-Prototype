extends Node

var question = []
var current_question_index: int = 0
var timer_value: int = 0
var correct_answer_index: int = 0
var max_question: int = 5

@export var question_label: Label
@export var timer_label: Label
@export var button_1: Button
@export var button_2: Button
@export var button_3: Button

@onready var timer: Timer = $Timer

func _ready():
	load_questions()
	show_question(current_question_index)

	button_1.connect("pressed", Callable(self, "_on_choice_pressed").bind(0))
	button_2.connect("pressed", Callable(self, "_on_choice_pressed").bind(1))
	button_3.connect("pressed", Callable(self, "_on_choice_pressed").bind(2))

# Load the questions from the JSON file
# This function reads the JSON file, parses the content and stores it in the question array
# The questions are then shuffled to randomize the order
func load_questions() -> void:
	var file = FileAccess.open("res://Questions/Questions.json", FileAccess.READ)

	if file:
		var json_data = file.get_as_text()
		question = JSON.parse_string(json_data)
		file.close()
	else:
		print("Failed to open file or file does not exist")
	
	question.shuffle()

# Shows the question and its choices to the user
# The question is fetched from the question array based on the given index
# The timer is started with the time given in the question data
# The correct answer is shuffled along with the other choices
# The correct answer index is stored in correct_answer_index
func show_question(index: int) -> void:
	var question_data = question[index]
	question_label.text = question_data["question"]
	timer_value = question_data["time"]
	correct_answer_index = question_data["answer"]
	update_timer_display()

	var choices = question_data["choices"].duplicate()
	var correct_answer = choices[correct_answer_index]
	choices.shuffle()

	correct_answer_index = choices.find(correct_answer)

	button_1.text = choices[0]
	button_2.text = choices[1]
	button_3.text = choices[2]

	timer.start(1)

# Handles the event when a choice is pressed.
# Checks if the selected choice is correct and shows feedback.
# Then moves to the next question or ends the game if all questions have been answered.
func _on_choice_pressed(choice_index: int) -> void:
	if choice_index == correct_answer_index:
		show_feedback(true)
	else:
		show_feedback(false)

	current_question_index += 1
	
	if current_question_index < max_question and current_question_index < question.size():
		show_question(current_question_index)
	else:
		print("Game over!")

func _on_timer_timeout() -> void:
	timer_value -= 1
	
	update_timer_display()

	if timer_value <= 0:
		print("Time's up!")
		timer.stop()
	
func update_timer_display() -> void:
	if timer_value >= 0:
		timer_label.text = str(timer_value)

func show_feedback(is_correct: bool) -> void:
	if is_correct:
		print("Correct!")
	else:
		print("Incorrect!")