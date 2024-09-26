extends CharacterBody2D


@onready var projectile = load("res://recource/projectile.tscn")


@export var MAX_SPEED = 420.0
@export var JUMP_VELOCITY = -700.0
@export var WALL_SLIDE_SPEED = 100.0
@export var SLIDE_SPEED = 400
@export var CROUCH_SLOWDOWN = 0.5
@export var GRAVITY = 1200.0
@export var FALL_GRAVITY_MULTIPLIER = 1.5
@export var JUMP_GRAVITY_MULTIPLIER = 0.7
@export var DASH_SPEED = 600
@export var DASH_TIME = 0.2
@export var idle_delay = 2.5

@export var TILE_FALL = 42  # The base distance at which tiles will fall
@export var LEVEL_NUMBER = 1  # Current level number (affects fall distance)
@export var tile_of_death: PackedScene  # The tile scene to be spawned
@export var player_node: NodePath

var player
var idle_timer = 0.0
const double_jump_modifier = 1.5
const acceleration = 5
var dir = 1 # 1 is right and -1 is left 0 is standing
var double_jump = 1
var dash_count = 1
var dashing = false
var dash_timer = 0.0
var max_slide_time = 2.0
var slide_time = max_slide_time
var last_dir = 0
var WJ_pushback = 420
var last_wall_dir = 0 # To track the direction of the last wall jump (left or right)
var running = false
var crouching = false
var run_multiplier = 3
var projectile_count = 4

var distance_moved = 0.0  # Track total distance moved by the player
var last_position = Vector2.ZERO  # Last position of the player
var tile_fall_distance = 0  # Distance the player needs to move for a tile to fall
var dead = false

@onready var walking_sound = $Walking
@onready var jumping_sound = $Jumping

func walking(delta) -> void:
	walking_sound.pitch_scale = 1.0 
	if dir != 0 and is_on_floor() == true and not walking_sound.playing:
		walking_sound.play()  

	if dir == 0 or not is_on_floor():
		walking_sound.stop()
	# Accelerate when moving left or right
	if dir != 0:
		velocity.x += dir * (MAX_SPEED / acceleration)
		# Clamp the velocity to max speed when not running
		if not Input.is_action_pressed("sprint"):
			velocity.x = clamp(velocity.x, -MAX_SPEED, MAX_SPEED)
		idle_timer = 0.0
		$AnimatedSprite2D.animation = "walk"
		$AnimatedSprite2D.play()
		$AnimatedSprite2D.flip_h = velocity.x < 0
	else:
		# Decelerate smoothly when no input is given
		velocity.x = 0#lerp(velocity.x, 0.0, 0.1)
		
		# Stop tiny movement to avoid sliding when very close to 0
		if abs(velocity.x) < 0.1:
			velocity.x = 0
		if velocity.x == 0 and velocity.y == 0 and is_on_floor():
			$AnimatedSprite2D.stop()
			idle_timer += delta  # Increment idle timer
			if idle_timer >= idle_delay:
				$AnimatedSprite2D.animation = "idle"
				$AnimatedSprite2D.play()
func run(delta) -> void:
	walking_sound.pitch_scale = 1.5
	
	# Play walking sound when running on the floor
	if dir != 0 and is_on_floor() and not walking_sound.playing:
		walking_sound.play()
	if dir == 0 or not is_on_floor():
		walking_sound.stop()
	
	# Running logic
	if dir != 0 and Input.is_action_pressed("sprint") and not is_on_wall():
		velocity.x += dir * (MAX_SPEED * run_multiplier / acceleration)
		velocity.x = clamp(velocity.x, -MAX_SPEED * run_multiplier, MAX_SPEED * run_multiplier)
		idle_timer = 0.0
		if is_on_floor() == true :
			$AnimatedSprite2D.animation = "run"
			$AnimatedSprite2D.play()
		$AnimatedSprite2D.flip_h = velocity.x < 0
	else:
		# When player stops moving or is not sprinting
		if velocity.x == 0 and velocity.y == 0 and is_on_floor():
			idle_timer += delta
			
			if idle_timer < idle_delay:
				$AnimatedSprite2D.animation = "stand"
			else:
				$AnimatedSprite2D.animation = "idle"
			
			$AnimatedSprite2D.play()
			$AnimatedSprite2D.flip_h = last_dir < 0  # Ensure the player faces the correct direction

func jump() -> void:
	if Input.is_action_just_pressed("jump"):
		print("Jump Pressed!")
		
		# Ground jump
		if is_on_floor():
			velocity.y = JUMP_VELOCITY
			double_jump = 1  # Reset double jump when landing on the ground
			last_wall_dir = 0  # Reset wall jump tracking when on the ground
			print("Jumping from the floor! velocity.y =", velocity.y)
			jumping_sound.play()

		# Double jump (in air, not on wall)
		elif not is_on_floor() and double_jump >= 1 and not is_on_wall():
			velocity.y = JUMP_VELOCITY / double_jump_modifier
			double_jump -= 1
			print("Performing a double jump! velocity.y =", velocity.y)
			jumping_sound.play()
		
		# Wall jump (ensure it's a different wall than last jump)
		elif is_on_wall() and last_dir != last_wall_dir:
			velocity.y = 0
			velocity.y = JUMP_VELOCITY
			velocity.x += WJ_pushback * -last_dir
			last_wall_dir = last_dir
			dir = -dir
			print("Wall jump! velocity.y =", velocity.y)
			jumping_sound.play()

		print("Playing jump animation")
		$AnimatedSprite2D.animation = "jump"
		$AnimatedSprite2D.flip_h = velocity.x < 0
		$AnimatedSprite2D.play()

	# After the jump, check if the player is in the air and standing still vertically
	if not is_on_floor():
		if abs(velocity.y) == 0:  # If the player's vertical velocity is close to 0, transition to stand animation
			$AnimatedSprite2D.animation = "stand"
			$AnimatedSprite2D.play()

func dash(delta) -> void:
	# Trigger dash if the player presses dash, is not on the ground, and has dashes available
	if Input.is_action_just_pressed("dash") and not is_on_floor() and dash_count > 0 and not dashing:
		dashing = true
		dash_timer = DASH_TIME  # Set dash duration
		velocity.x = DASH_SPEED * dir  # Set dash speed in the current direction
		velocity.y = 0  # Cancel vertical movement during the dash
		dash_count -= 1  # Decrease available dash count
		
		$AnimatedSprite2D.animation = "dash"
		$AnimatedSprite2D.play()

	# Handle dash duration
	if dashing:
		dash_timer -= delta
		if dash_timer <= 0:
			dashing = false  # End dash when the timer runs out

func wall_slide(delta: float) -> void:
	if dir != 0:
		velocity.x += dir * (MAX_SPEED / acceleration)
		# Clamp the velocity to max speed when not running
		if not Input.is_action_pressed("sprint"):
			velocity.x = clamp(velocity.x, -MAX_SPEED, MAX_SPEED)
	if is_on_wall() and not is_on_floor() and dir != 0:
		velocity.y += WALL_SLIDE_SPEED * delta
		velocity.y = clamp(velocity.y, -INF, WALL_SLIDE_SPEED)
		

		var collision = get_last_slide_collision()

		if collision:
			var collision_normal = collision.get_normal()
			if collision_normal.x > 0:
				$AnimatedSprite2D.flip_h = true
			else:
				$AnimatedSprite2D.flip_h = false
			$AnimatedSprite2D.animation = "wall_slide"
			$AnimatedSprite2D.play()
		else :
			$AnimatedSprite2D.stop()
			if velocity.x == 0 and velocity.y == 0 and is_on_floor():
				idle_timer += delta
				
				if idle_timer < idle_delay:
					$AnimatedSprite2D.animation = "stand"
				else:
					$AnimatedSprite2D.animation = "idle"
				
				$AnimatedSprite2D.play()
				$AnimatedSprite2D.flip_h = last_dir < 0
	
func crouch_n_slide(delta: float) -> void:
	# Check if crouch (Ctrl) is pressed
	if Input.is_action_pressed("crouch"):
		if dir != 0 and abs(velocity.x) >= SLIDE_SPEED:
			print("Sliding")
			velocity.x = lerp(velocity.x, 0.0, delta * 2)  # Gradually slow down the slide
			slide_time -= delta
			crouching = true
			$AnimatedSprite2D.animation = "slide"
			$AnimatedSprite2D.flip_h = velocity.x < 0
			$AnimatedSprite2D.play()
			$"normal hitbox".disabled = true
			$"sliding hitbox".disabled = false  # Use sliding hitbox
		else:
			print("Crouching")
			# Player is crouching but not sliding
			crouching = true
			$AnimatedSprite2D.animation = "crouch"
			$AnimatedSprite2D.flip_h = velocity.x < 0
			$AnimatedSprite2D.play()

			# Crouch + Move (Ctrl + left/right)
			if dir != 0:
				velocity.x = dir * (MAX_SPEED * CROUCH_SLOWDOWN)  # Slower movement while crouching
			else:
				velocity.x = 0  # No movement if no directional input

			$"normal hitbox".disabled = true
			$"sliding hitbox".disabled = false  # Use crouching hitbox
	else:
		# Player stops crouching or sliding
		crouching = false
		slide_time = max_slide_time  # Reset slide time
		$"normal hitbox".disabled = false
		$"sliding hitbox".disabled = true  # Switch back to normal hitbox
		
func apply_gravity(delta: float) -> void:
	#if is_on_floor():
	#	velocity.y = 0
	#	print("In apply gravity floor! velocity.y =", velocity.y)
	#else:
		if velocity.y < 0:
			velocity.y += GRAVITY * JUMP_GRAVITY_MULTIPLIER * delta
			#print("In apply gravity jump! velocity.y =", velocity.y)
		else:
			velocity.y += GRAVITY * FALL_GRAVITY_MULTIPLIER * delta
			#print("In apply gravity falls! velocity.y =", velocity.y)

func reset_abilities_on_land(delta: float) -> void:
	if is_on_floor():
		double_jump = 1
		dash_count = 1
		slide_time = max_slide_time
		
	if not Input.is_action_pressed("crouch"):
		slide_time = clamp(slide_time + delta, 0, max_slide_time)

func spawn_falling_tile(player: Node) -> void:
	var tile = tile_of_death.instantiate()
	tile.gravity = GRAVITY * 5
	# Set the spawn position for the falling tile
	var spawn_position = Vector2(last_position.x + 50, player.position.y - 200)  # Spawn above the player
	tile.position = spawn_position
	
	# Add the tile to the scene
	get_parent().add_child(tile)
	tile.set_player(player)

func _physics_process(delta: float) -> void:
	# Track the distance moved
	
	#print("Player position: ", player.position)
	
	var movement_delta = abs(player.position.x - last_position.x)
	distance_moved += movement_delta
	last_position = player.position
	#print("Distance moved: ", distance_moved, " | Tile fall distance: ", tile_fall_distance)
	# Spawn tile after moving tile_fall_distance
	if distance_moved >= tile_fall_distance:
		spawn_falling_tile(player)
		distance_moved = -100  # Reset distance after tile spawns
		
	dir = Input.get_axis("move_left", "move_right")
	if dir != 0:
		last_dir = dir
	if is_on_wall() and not is_on_floor():
		wall_slide(delta)  # Perform wall sliding
	elif Input.is_action_pressed("crouch"):
		crouch_n_slide(delta)  # Handle crouching and sliding
	else:
		if Input.is_action_pressed("sprint"):
			run(delta)  # Handle running
		else:
			walking(delta)  # Handle walking
	jump()
	dash(delta)
	apply_gravity(delta)
	move_and_slide()
	shoot()
	death()
	#print("Velocity after move_and_slide:", velocity)
	reset_abilities_on_land(delta)
	if velocity.x == 0 and velocity.y == 0 and is_on_floor():
			$AnimatedSprite2D.stop()
			
	var overlapping_traps = %HurtZone.get_overlapping_areas()
	
	if overlapping_traps.size() > 0:
		dead = true
	
	if dead:
		get_tree().change_scene_to_file("res://resources/last main/death_screen.tscn")
	if Input.is_action_pressed("RESET"):
		get_tree().change_scene_to_file("res://resources/last main/starting screen.tscn")

	
func shoot():
	if Input.is_action_just_pressed("shoot") and not projectile_count <= 0:
		var instance = projectile.instantiate()
		instance.dir = rotation
		instance.spawnPos = global_position
		instance.spawnRot = rotation
		$"..".call_deferred("add_child", instance)
		projectile_count -= 1
		
func death():
	if position.y >= 10000:
		dead = true
	pass
	
func	 _ready() -> void:
	player = get_node(player_node)
	last_position = player.position  # Set the initial position of the player
	tile_fall_distance = TILE_FALL / LEVEL_NUMBER  # Calculate the fall distance based on the level
	$"normal hitbox".disabled = false
	$"sliding hitbox".disabled = true
