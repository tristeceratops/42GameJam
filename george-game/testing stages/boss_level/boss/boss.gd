extends Node2D

func wait(seconds: float) -> void:
	await get_tree().create_timer(seconds).timeout

func combat():
	print("combat")
	get_node("Sprite2D/AnimatedSprite2D").play("default")
