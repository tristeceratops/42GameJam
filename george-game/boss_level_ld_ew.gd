extends Node2D

var COMBAT_STARTED = false

func _process(delta: float) -> void:
	var is_overlapCamera = %BossCameraArea.get_overlapping_bodies()
	for bodies: Node2D in is_overlapCamera:
		if bodies.is_in_group("player"):
			%BossCamera.make_current()
			if !COMBAT_STARTED:
				COMBAT_STARTED = true
				%Background.stop()
				%BossMusic.play()
				%Boss.call("combat")
		else:
			%PlayerCamera.make_current()
