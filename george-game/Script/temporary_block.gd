extends CharacterBody2D

var is_platform = true

func _physics_process(delta: float) -> void:
	$"keaboard platform".disabled = is_platform

func _on_area_2d_area_entered(area: Area2D) -> void:
	is_platform = false
