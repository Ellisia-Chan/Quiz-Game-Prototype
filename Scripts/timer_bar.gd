extends ProgressBar

var quiz_ui_script
var timer_value = 0.0
var elapsed_time = 0.0

func _ready():
	# Connect to the signal emitted when a question is shown
	quiz_ui_script = get_parent()
	quiz_ui_script.connect("on_question_show", Callable(self, "_update_progress_bar"))

func _process(delta):
	# Update progress bar if there's a timer active
	if timer_value > 0:
		elapsed_time += delta
		var remaining_time = max(0, timer_value - elapsed_time)
		self.value = (remaining_time / timer_value) * 100

		# Stop updating if time runs out
		if remaining_time <= 0:
			timer_value = 0 # Ensure the timer doesn't go negative

func _update_progress_bar():
	# Initialize the timer and progress bar
	timer_value = quiz_ui_script.timer_value
	elapsed_time = 0.0
	self.value = 100 # Reset the progress bar to full