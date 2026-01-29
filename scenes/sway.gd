extends Node3D

var mouse_move : float = 0.0
var sway_thresh = 5
var sway_lerp = 5

@export var sway_left : Vector3
@export var sway_right : Vector3
@export var sway_normal : Vector3


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func _input(event):
	if event is InputEventMouseMotion:
		mouse_move = -event.relative.x

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if mouse_move == null:
		return
		
	if mouse_move > sway_thresh:
		rotation = rotation.lerp(sway_left, sway_lerp * delta)
	elif mouse_move < -sway_thresh:
		rotation = rotation.lerp(sway_right, sway_lerp * delta)
	else: 
		rotation = rotation.lerp(sway_normal, sway_lerp * delta)
