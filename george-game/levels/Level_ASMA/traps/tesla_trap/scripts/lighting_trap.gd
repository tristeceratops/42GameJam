extends Node2D

func _ready():
	var animation_player = get_node("%TrapAnimPlayer")
	var animation_name = "trap"  # Replace with your animation name
	
	if animation_player.has_animation(animation_name):
		var animation = animation_player.get_animation(animation_name)
		animation.loop = true
		
		# Optionally, play the animation
		animation_player.play(animation_name)
