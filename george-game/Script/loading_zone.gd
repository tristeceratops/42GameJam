extends Node2D


@export var next_level : String


func _on_area_2d_body_entered(body: Node2D) -> void:
	get_tree().change_scene_to_file(next_level)
