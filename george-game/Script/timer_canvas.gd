extends CanvasLayer

@export var initial_time: int = 42  # Starting time for the countdown
@onready var game_over = $Gameover
@onready var background_sound = $Background
@onready var countdown_timer = $TimerCanvas
var time_to_die = 0
var current_time: int = 0  # Tracks remaining time
signal time_ran_out  # Signal emitted when time reaches zero
signal rush

func wait(seconds: float) -> void:
	await get_tree().create_timer(seconds).timeout

func _ready() -> void:
	current_time = initial_time  # Initialize the current time
	$Countdown_label.text = str(current_time)  # Display the current time in the label
	$Countdown_timer.start()  # Start the timer

	# Connect the Timer's timeout signal in Godot 4.x
	$Countdown_timer.timeout.connect(_on_countdown_timeout)
	#countdown_timer.rush.connect(_final_secs)

# Function called each second
func _on_countdown_timeout() -> void:
	current_time -= 1  # Decrease the time by 1 second
	$Countdown_label.text = str(current_time)  # Update the label with the new time
	
	if current_time <= 10:
		emit_signal("rush")
	
	if current_time <= 0:
		game_over.play()
		emit_signal("time_ran_out")  # Emit signal when time reaches zero
		$Countdown_timer.stop()  # Stop the timer
		await get_tree().create_timer(2.5).timeout
		get_tree().change_scene_to_file("res://recource/death_screen.tscn")


func _final_secs() -> void:
	background_sound.pitch_scale = 1.5
