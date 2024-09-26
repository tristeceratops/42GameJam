extends CanvasLayer

@export var initial_time = 42  # Starting time for the countdown
var current_time = 0  # Variable to store the remaining time
signal time_ran_out  # Signal to notify when the timer reaches zero

func _ready() -> void:
	current_time = initial_time  # Initialize the timer
	$CountdownLabel.text = str(current_time)  # Set initial label text
	$CountdownTimer.start()  # Start the countdown timer
	$CountdownTimer.timeout.connect(_on_countdown_timeout)  # Connect timeout signal

# Function to handle each second of countdown
func _on_countdown_timeout() -> void:
	current_time -= 1
	$CountdownLabel.text = str(current_time)  # Update the label with the current time
	
	if current_time <= 0:
		emit_signal("time_ran_out")  # Emit the signal when time runs out
		$CountdownTimer.stop()  # Stop the timer

# Optional: You can add a function to reset or adjust the timer during the game
func reset_timer(time: int) -> void:
	current_time = time
	$CountdownLabel.text = str(current_time)
	$CountdownTimer.start()
