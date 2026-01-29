extends Area3D

const damage_numbers = preload("res://scenes/damage_numbers.tscn")
var dmg_numbers
var crit : bool = false

func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("bolts"):
		dmg_numbers = damage_numbers.instantiate()
		get_parent().add_child(dmg_numbers)
		dmg_numbers.global_position = $"../Marker3D".global_position
		body.hit()
		dmg_numbers.set_and_play(body.damage, crit, body.orange_breakpoint)
