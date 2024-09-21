extends CharacterBody2D

# Variables for movement
@export var max_speed: float = 100.0  # Maximum speed of the platform
var acceleration: float = 420.0  # Rate of acceleration
var deceleration: float = 420.0  # Rate of deceleration
var current_speed: float = 0.0  # Current speed of the platform
var direction: int = 1  # Initial direction (1 = right, -1 = left)
@export var left_limit: float = 0  # The left limit in the X-axis
@export var right_limit: float = 300  # The right limit in the X-axis


func _physics_process(delta: float):
	# Decelerate when near the limits
	if (direction == 1 and position.x >= right_limit - 50) or (direction == -1 and position.x <= left_limit + 50):
		current_speed = max(current_speed - deceleration * delta, 0)
		# If fully decelerated, reverse direction
		if current_speed == 0:
			direction *= -1  # Reverse the direction
	else:
		# Accelerate while moving normally
		current_speed = min(current_speed + acceleration * delta, max_speed)

	# Move the platform based on current speed and direction
	position.x += current_speed * direction * delta
