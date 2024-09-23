extends CharacterBody2D
#for the projectile
@onready var projectile = load("res://recources/projectile.tscn")



var MAX_SPEED = 420.0
const JUMP_VELOCITY = -700.0
const acceleration = 5
var dir = 1 # 1 is right and -1 is left 0 is standing
var doubble_jump = 1
var dash_count = 1
var max_slide_time = 2.0
var slide_time = max_slide_time
var last_dir = 0
var WJ_pushback = 420
var wall_slide_fr = 100
var last_wall_dir = 0 # To track the direction of the last wall jump (left or right)
var projectile_count = 4
var running = false
var crouching = false


func _ready():
	pass


func _physics_process(delta: float) -> void:
	dir = Input.get_axis("left", "right")
	if dir != 0:
		last_dir = dir
	crouch_n_slide(delta)
	jump()
	dash()
	run()
	walking()
	wall_slide(delta)
	shoot()
	sling()
	
	returning_the_points(delta)
	gravity(delta)
	
	if position.y >= 1000:
		get_tree().reload_current_scene()
	
	move_and_slide()

func jump() -> void:
	if Input.is_action_just_pressed("jump"):
			# Ground jump
		if is_on_floor():
			velocity.y += JUMP_VELOCITY
			doubble_jump = 1 # Reset double jump when landing on the ground
			last_wall_dir = 0 # Reset wall jump tracking when on the ground

				# Double jump (in air, not on wall)
		elif not is_on_floor() and doubble_jump >= 1 and not is_on_wall():
			velocity.y = 0
			velocity.y += JUMP_VELOCITY / 1.5
			doubble_jump -= 1

				# Wall jump (ensure it's a different wall than last jump)
		elif is_on_wall() and not is_on_floor() and last_dir != last_wall_dir:
			velocity.y = 0 # Reset Y velocity
			velocity.y += JUMP_VELOCITY # Apply wall jump velocity
			velocity.x += WJ_pushback * -last_dir # Push away from the wall

			last_wall_dir = last_dir # Track the direction of the wall jump
			dir = -dir # Flip direction


func wall_slide(delta):
	if is_on_wall() and not is_on_floor() and dir != 0:
		velocity.y += wall_slide_fr * delta
		velocity.y = min(velocity.y, wall_slide_fr)


func returning_the_points(delta):
	if is_on_floor():
		doubble_jump = 1
		if dash_count != 1:
			dash_count += delta
	if not Input.is_action_pressed("down"):
		if slide_time != max_slide_time:
			slide_time += delta

func crouch_n_slide(delta):
	if Input.is_action_pressed("down") and Input.is_action_pressed("run") and crouching == false and abs(velocity.x) >= 400 and slide_time > 0 and not velocity.x == 0:
		#velocity.y += 420
		velocity.x -= 0.001 * MAX_SPEED * -last_dir
		velocity.y = abs(velocity.x) / 1.5
		slide_time -= delta
		$"normal hitbox".disabled = true
	elif Input.is_action_pressed("down"):
		velocity.y += 420
		velocity.x /= 2
		crouching = true
		$"normal hitbox".disabled = true
	else:
		$"normal hitbox".disabled = false
		crouching = false
	

func run()-> void:
	if dir != 0 and Input.is_action_pressed("run") and not is_on_wall() and is_on_floor():
		velocity.x += dir * (MAX_SPEED * 3 / acceleration)
	if abs(velocity.x) > MAX_SPEED * 3 and not is_on_wall():
		velocity.x = MAX_SPEED * 3 * dir

func dash() -> void:
	if Input.is_action_just_pressed("dash") and not is_on_floor() and dash_count > 0:
		velocity.x += 210 * dir
		dash_count -= 1
		move_and_collide(Vector2(velocity.x, 0))
		
func walking() -> void:
	# Accelerate when moving left or right
	if dir != 0:
		velocity.x += dir * (MAX_SPEED / acceleration)
		
		# Clamp the velocity to the maximum speed
	if abs(velocity.x) > MAX_SPEED and not Input.is_action_pressed("run"):
		velocity.x = MAX_SPEED * dir
	else:
			# Decelerate smoothly when no input is given
		if velocity.x != 0:
			velocity.x = lerp(velocity.x, 0.0, 0.1)  # Lerp for smooth deceleration

		# Stop small movements (to avoid sliding)
	if abs(velocity.x) < 0.1:
		velocity.x = 0
func animation():
	pass
	
	
	
func shoot():
	if Input.is_action_just_pressed("shoot") and not projectile_count <= 0:
		var instance = projectile.instantiate()
		instance.dir = rotation
		instance.spawnPos = global_position
		instance.spawnRot = rotation
		$"..".call_deferred("add_child", instance)
		projectile_count -= 1
		
func sling():

	pass

	
func gravity(delta) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
