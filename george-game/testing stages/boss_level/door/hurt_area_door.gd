extends AnimatedSprite2D


var IS_OPEN = false

func _on_animation_finished() -> void:
	print("anim finish")
	set_frame(4)
	$StaticBody2D/CollisionShape2D.disabled = true


func _on_hurt_area_area_entered(area: Area2D) -> void:
	print("entered the area")
	if area.is_in_group("projectile_keyboard") && !IS_OPEN:
		play("open_door")
		IS_OPEN = true
