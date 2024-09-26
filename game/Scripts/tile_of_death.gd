extends CharacterBody2D

@export var gravity = 1200.0  # Gravity force for the tile
@export var remove_velocity_threshold = 0.1  # Threshold to check if the tile has stopped moving
@onready var game_over = $Gameover

var player_node: Node = null  # Dynamically assign the player node

func _physics_process(delta: float) -> void:
	# Apply gravity to make the tile fall
	velocity.y += gravity * delta

	# Handle tile movement and collision detection with `move_and_collide()`
	var collision = move_and_collide(velocity * delta)
	
	if collision:
		# Check if the colliding object is the player
		if player_node and collision.get_collider() == player_node:  # Check if the collider is the player
			print("You Died")
			show_you_died_message()  # Show the message and restart the game
		#else:
			# Check if the tile has landed (velocity becomes close to zero)
			#queue_free()  # Remove the tile from the scene

# Function to set the player node dynamically
func set_player(player: Node) -> void:
	player_node = player  # Assign the player node reference dynamically
	print("Player node assigned dynamically:", player_node.name)

# Show "You Died" and restart the game
func show_you_died_message() -> void:
	game_over.play()
	# Display "You Died" and wait 1.5 seconds before restarting the game
	var you_died_label = get_node("CanvasLayer/YouDiedLabel")
	
	# Display "You Died" and make the label visible
	you_died_label.text = "You Died"  # Set the text
	you_died_label.visible = true  # Make it visible
	
	# Wait for a brief moment before restarting the game
	await get_tree().create_timer(1.5).timeout  # Wait 1.5 seconds
	game_over.stop()
	# Restart the game by reloading the current scene
	get_tree().reload_current_scene()
