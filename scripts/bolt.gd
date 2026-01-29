extends CharacterBody3D

# Stats
var SPEED = 500
var damage_min = 3
var damage_max = 8
var crit_chance = 0.05
var orange_crit_multi = 1.3
var orange_breakpoint: float
var damage

# Effects
@onready var particles = $GPUParticles3D
@onready var mesh = $MeshInstance3D
@onready var smoke = $trail

# Collision
@export var owner_body: PhysicsBody3D
var last_pos: Vector3

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# damage calcs
	var attack = owner_body.attack_scaling
	var armor = 0
	orange_breakpoint = damage_max * (1.0 - crit_chance) * attack
	damage = randi_range(damage_min, damage_max) # random damage range
	if damage >= orange_breakpoint:
		damage *= orange_crit_multi
	var reduction = armor / (armor + 100.0)
	damage = int(damage * attack * (1.0 - reduction))
	
	add_to_group("bolts")
	add_collision_exception_with(owner_body)
	last_pos = global_position
	get_tree().create_timer(2).timeout.connect(queue_free)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	position = global_position + -global_transform.basis.z * SPEED * delta
	var space = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(last_pos, position)
	var result = space.intersect_ray(query)
	
	if result:
		global_position = result.position
		hit()
		
	global_position = position
	last_pos = global_position
	
	
func hit():
	mesh.visible = false
	particles.emitting = true
	smoke.emitting = true
	await get_tree().create_timer(0.5).timeout
	queue_free()
