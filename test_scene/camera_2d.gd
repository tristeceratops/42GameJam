extends Camera2D

# Speed of the camera movement
var speed = 200.0

func _process(delta):
	var direction = Vector2.ZERO

	if Input.is_action_pressed("ui_up"):
		direction.y -= 1
	if Input.is_action_pressed("ui_down"):
		direction.y += 1
	if Input.is_action_pressed("ui_left"):
		direction.x -= 1
	if Input.is_action_pressed("ui_right"):
		direction.x += 1

	# Normalize the direction to ensure consistent speed
	if direction != Vector2.ZERO:
		direction = direction.normalized()

	# Move the camera
	position += direction * speed * delta
