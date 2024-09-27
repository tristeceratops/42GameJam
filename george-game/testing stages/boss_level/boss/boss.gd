extends Node2D

var POINT_ARRAY = [get_node("Sprite2D/ShootingMarker1"), get_node("Sprite2D/ShootingMarker2"),
				   get_node("Sprite2D/ShootingMarker3"), get_node("Sprite2D/ShootingMarker4")]
var HP = 4
var PROJ = ["0_proj", "1_proj"]
var SPEED = 800  # Horizontal speed
var RANGE = 800
var DEAD = false

func _ready():
	var timer = get_node("Timer")
	timer.start()
	
	var hurt_area = get_node("Sprite2D/HurtBox")
	var anim_sprite = get_node("Sprite2D/AnimatedSprite2D")
	hurt_area.area_entered.connect(_on_HurtArea_area_entered)
	anim_sprite.animation_finished.connect(_on_AnimatedSprite_animation_finished)

func combat():
	print("combat")
	get_node("Sprite2D/AnimatedSprite2D").play("default")
	shoot()

func shoot():
	var boss_animated_sprite = get_node("Sprite2D/AnimatedSprite2D")
	boss_animated_sprite.play("shoot")
	for i in range(5):
		var point = POINT_ARRAY[randi() % POINT_ARRAY.size()]
		var project_scene = preload("res://testing stages/boss_level/boss/boss_project.tscn")
		var project = project_scene.instantiate()
		project.scale = Vector2(8, 8)
		
		# Set the position of the projectile to the random point
		project.position = point.position

		# Access the AnimatedSprite node within the projectile
		var animated_sprite = project.get_node("AnimatedSprite2D")
		
		# Set the animation to play and loop
		animated_sprite.animation = PROJ[randi() % PROJ.size()]
		animated_sprite.play()
		
		# Set a random direction for the projectile
		var direction = Vector2(randf() * 2 - 1, randf() * 2 - 1).normalized()
		project.velocity = direction * SPEED
		
		# Add the projectile to the scene tree
		add_child(project)

func _on_timer_timeout() -> void:
	if !DEAD:
		shoot()

func _on_boss_camera_area_area_exited(area: Area2D) -> void:
	if area.name == "area_0" or area.name == "area_1": #not working
		print("free mem")
		area.queue_free()

func _on_HurtArea_area_entered(area: Area2D) -> void:
	if area.is_in_group("projectile_keyboard"):
		HP -= 1
		area.queue_free()  # Remove the projectile
		var animated_sprite = get_node("Sprite2D/AnimatedSprite2D")
		if HP == 3:
			animated_sprite.play("hurt")
			get_node("BossBroken1").visible = true
		if HP == 2:
			animated_sprite.play("hurt")
			get_node("BossBroken2").visible = true
		if HP == 1:
			animated_sprite.play("hurt")
			get_node("BossBroken3").visible = true
		if HP <= 0:
			DEAD = true
			animated_sprite.play("death")
			print("Boss defeated")

func _on_AnimatedSprite_animation_finished() -> void:
	if get_node("Sprite2D/AnimatedSprite2D").animation == "die":
		print("VICTORY")
		#queue_free()  # does not work
		 # Call victory scene
