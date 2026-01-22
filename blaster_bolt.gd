extends Node3D

@export var SPEED = 250

@onready var mesh = $MeshInstance3D
@onready var raycast = $RayCast3D
@onready var animation_player = $AnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	animation_player.play("flight") # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	position += transform.basis * Vector3(0, 0, -SPEED) * delta
	if raycast.is_colliding():
		mesh.visible = false
		await get_tree().create_timer(1.0).timeout
		queue_free()
		
func _on_timer_timeout():
	queue_free()
