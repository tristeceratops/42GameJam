extends CanvasLayer

@export var initial_time: int = 42  # Starting time for the countdown
@onready var game_over = $Gameover
var current_time: int = 0  # Tracks remaining time
signal time_ran_out  # Signal emitted when time reaches zero


func _ready() -> void:
	current_time = initial_time  # Initialize the current time
	$Countdown_label.text = str(current_time)  # Display the current time in the label
	$Countdown_timer.start()  # Start the timer

	# Connect the Timer's timeout signal in Godot 4.x
	$Countdown_timer.timeout.connect(_on_countdown_timeout)

# Function called each second
func _on_countdown_timeout() -> void:
	current_time -= 1  # Decrease the time by 1 second
	$Countdown_label.text = str(current_time)  # Update the label with the new time

	if current_time <= 0:
		game_over.play()
		emit_signal("time_ran_out")  # Emit signal when time reaches zero
		$Countdown_timer.stop()  # Stop the timer
