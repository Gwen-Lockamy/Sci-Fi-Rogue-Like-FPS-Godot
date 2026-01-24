extends CharacterBody3D

# Player Physics 
const WALK_SPEED = 3.8
const SPRINT_SPEED =  6
const JUMP_VELOCITY = 4.5
const AIR_CONTROL = 3.0
const STEP_INTERVAL = 0.4
var step_timer = 0
var gravity = 9.8
var movement_speed

# Camera Juice
const SENSITIVITY = 0.0015
const BOB_FREQUENCY = 2.0
const BOB_AMPLITUDE = 0.06
const FOV_CHANGE = 1.05
var base_fov = 85
var time_bob = 0.0

# Misc
var bullet = load("res://scenes/blaster_bolt.tscn")
var shoot_blend = 0.0
var instance

# Node Pointers
@onready var head = $Head
@onready var camera = $Head/Camera3D
@onready var weapon = $Head/Camera3D/WeaponRig
@onready var player_animations = $AnimationPlayer
@onready var gun_animation = $Head/Camera3D/WeaponRig/Blaster/AnimationPlayer
@onready var gun_barrel = $Head/Camera3D/WeaponRig/Blaster/RayCast3D
@onready var light = $Head/Camera3D/WeaponRig/Blaster/OmniLight3D
@onready var blaster_sound = $Head/Camera3D/WeaponRig/Blaster/"Blaster Sound"
@onready var anim_tree = $AnimationTree
@onready var footstep_audio = $Step

# Mouse Camera Rotation
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		head.rotate_y(-event.relative.x * SENSITIVITY)
		camera.rotate_x(-event.relative.y * SENSITIVITY)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-80), deg_to_rad(80))

# BeforeAll Enable Mouse Capture
func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

# Physics Process Loop
func _physics_process(delta: float) -> void:
	# Gravity
	if not is_on_floor():
		velocity.y -= gravity * delta
	# Sprint
	if Input.is_action_pressed("sprint"):
		movement_speed = SPRINT_SPEED
	else:
		movement_speed = WALK_SPEED
	# Jump
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Input, Direction, Movement
	var input_dir := Input.get_vector("left", "right", "forward", "backward")
	var direction = (head.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
		
	# Head bob
	time_bob += delta * velocity.length() * float(is_on_floor())
	camera.transform.origin = headbob(time_bob)
	
	# FOV 
	var target_fov = base_fov + FOV_CHANGE * clamp(velocity.length(), 0.5, SPRINT_SPEED)
	camera.fov = lerp(camera.fov, target_fov, delta * 5.0) 
	
	handle_movement(direction, input_dir, delta)
	handle_shooting(delta)
	move_and_slide()

func headbob(time) -> Vector3:
	var pos = Vector3.ZERO
	pos.y = sin(time * BOB_FREQUENCY)  * BOB_AMPLITUDE
	pos.x = cos(time * BOB_FREQUENCY / 2) * BOB_AMPLITUDE
	return pos
	
func handle_shooting(delta):
	shoot_blend = lerp(shoot_blend, 0.0, delta * 4)
	anim_tree["parameters/Shooting/blend_amount"] = shoot_blend
	if Input.is_action_pressed("shoot"):
		if !gun_animation.is_playing():
			shoot_blend = 0.8
			blaster_sound.pitch_scale = randf_range(0.75, 0.85)
			gun_animation.play("shoot", -1, 2)

			instance = bullet.instantiate()
			instance.position = gun_barrel.global_position
			instance.transform.basis = gun_barrel.global_transform.basis
			get_parent().add_child(instance)

			
func handle_movement(direction, input_direction, delta):
	if is_on_floor():
		var speed_ratio = velocity.length() / SPRINT_SPEED
		anim_tree[&"parameters/Walk/blend_amount"] = clamp(speed_ratio, 0.0, 1.0)
		if speed_ratio > 0.1:
			step_timer += delta
			if step_timer >= STEP_INTERVAL:
				footstep_audio.pitch_scale = randf_range(0.4, 0.55)
				footstep_audio.play()
				step_timer = 0.0
		else:
			step_timer = 0.0
		# Directional Lean
		if input_direction.x:
			camera.rotation.z = lerp(camera.rotation.z, -input_direction.x * 0.02, 3 * delta)
		else:
			camera.rotation.z = lerp(camera.rotation.z, 0.0, 4 * delta)
		# Movement Physics, added weight/inertia via lerp
		if direction:
			velocity.x = lerp(velocity.x, direction.x * movement_speed, delta * 9.0)
			velocity.z = lerp(velocity.z, direction.z * movement_speed, delta * 9.0)	
		else:
			velocity.x = lerp(velocity.x, direction.x * movement_speed, delta * 6.0)
			velocity.z = lerp(velocity.z, direction.z * movement_speed, delta * 6.0)
	else:
		# In-air inertia // interpolate from initial to target velocity over time
		velocity.x = lerp(velocity.x, direction.x * movement_speed, delta * AIR_CONTROL)
		velocity.z = lerp(velocity.z, direction.z * movement_speed, delta * AIR_CONTROL)
	
