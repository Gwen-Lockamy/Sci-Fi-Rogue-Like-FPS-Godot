extends Node3D

@onready var label = $Anchor/Label3D
@onready var hop_on = $AnimationPlayer

var slide_distance = 0.1
var distance = randf_range(slide_distance, slide_distance+0.05)
var duration = 0.5

func set_and_play(value, crit, damage_tier_breakpoint):
	label.text = str(value)
	if crit:
		hop_on.play("red_damage")
	elif value < damage_tier_breakpoint:
		hop_on.play("white_damage")
	elif value >= damage_tier_breakpoint:
		hop_on.play("orange_damage")
	
		
	# Randomly slide left or right
	var direction = Vector3(randf_range(-1, 1), 0, randf_range(-1, 1)).normalized()
	var target_position = label.position + direction * distance
	
	# Animate using Tween
	var tween = create_tween()
	tween.tween_property(label, "position", target_position, duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(label, "modulate:a", 0.0, duration)  # fade out alpha
	tween.tween_callback(Callable(self, "remove"))
		
func remove():
	queue_free()
