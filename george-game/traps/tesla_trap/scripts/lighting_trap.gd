extends Node2D

@export var start_delay: float = 0.0

func _ready():
	var animation_player = get_node("%TrapAnimPlayer")
	if start_delay > 0.0:
		await get_tree().create_timer(start_delay).timeout  # Wait for the specified delay
		print("Starting trap after delay: ", start_delay)
	var animation_name = "trap"  # Replace with your animation name
	
	if animation_player.has_animation(animation_name):
		var animation = animation_player.get_animation(animation_name)
		animation.loop = true
		
		# Optionally, play the animation
		animation_player.play(animation_name)
