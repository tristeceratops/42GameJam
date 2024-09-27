extends CharacterBody2D

func _process(delta):
	position += velocity * delta
