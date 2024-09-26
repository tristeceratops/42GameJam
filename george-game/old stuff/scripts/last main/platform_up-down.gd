extends CharacterBody2D

# Export variables for customizing movement
@export var max_speed: float = 100.0  # Maximum speed of the platform
@export var acceleration: float = 420.0  # Rate of acceleration
@export var deceleration: float = 420.0  # Rate of deceleration
@export var direction: int = 1  # Initial direction (1 = up, -1 = down)
@export var distance: float = 300.0  # The total distance the platform moves

# Internal state
var current_speed: float = 0.0  # Current speed of the platform
var down_limit: float  # Calculated left limit based on starting position
var up_limit: float  # Calculated right limit based on starting position
var start_position: Vector2  # Store the initial position where the node is placed

func _ready():
	# Use the position where the node was first dropped in the scene as the starting position
	start_position = position
	# Calculate the left and right limits based on the starting position and distance
	if direction == 1:
		down_limit = start_position.y
		up_limit = start_position.y + distance
	elif direction == 1:
		down_limit = start_position.y + distance
		up_limit = start_position.y

func _physics_process(delta: float):
	# Decelerate when near the limits
	if (direction == 1 and position.y >= up_limit - 50) or (direction == -1 and position.y <= down_limit + 50):
		current_speed = max(current_speed - deceleration * delta, 0)
		# If fully decelerated, reverse direction
		if current_speed == 0:
			direction *= -1  # Reverse the direction
	else:
		# Accelerate while moving normally
		current_speed = min(current_speed + acceleration * delta, max_speed)

	# Apply movement based on the direction and current speed
	position.y += direction * current_speed * delta
