extends Node2D

@onready var countdown_timer = $TimerCanvas

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Connect the signal from the countdown timer
	countdown_timer.time_ran_out.connect(_on_time_ran_out)

func _on_time_ran_out() -> void:
	var you_died_label = $"TimerCanvas/YouDiedLabel"
	
	# Display "You Died" and make the label visible
	you_died_label.text = "You Died"  # Set the text
	you_died_label.visible = true  # Make it visible
	
	# Wait for a brief moment before restarting the game
	await get_tree().create_timer(1.5).timeout  # Wait 1.5 seconds
	
	# Restart the game by reloading the current scene
	get_tree().reload_current_scene()
