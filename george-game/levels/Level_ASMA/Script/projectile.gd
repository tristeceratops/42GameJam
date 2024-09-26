extends CharacterBody2D

@export var SPEED = 840  # Horizontal speed
@export var GRAVITY = 210  # Gravity to simulate the arc

var spawnPos : Vector2
var spawnRot : float
var dir : float

func _ready():
	# Set the initial position and rotation
	global_position = spawnPos
	global_rotation = spawnRot

	# Calculate direction towards the mouse
	var mouse_pos = get_global_mouse_position()
	var direction = (mouse_pos - global_position).normalized()

	# Set the direction based on the calculated vector
	dir = direction.angle()

	# Set the initial horizontal velocity towards the mouse
	velocity.x = SPEED * direction.x
	velocity.y = SPEED * direction.y  # Initial upward velocity if needed

func _physics_process(delta: float) -> void:
	# Apply gravity to the projectile's vertical velocity (arc effect)
	velocity.y += GRAVITY * delta

	# Move the projectile based on the current velocity
	move_and_slide()