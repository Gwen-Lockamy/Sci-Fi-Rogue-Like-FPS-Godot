extends WorldEnvironment

const FREQUENCY = 0.2
const AMPLITUDE = 0.1

var low_freq = FREQUENCY - 0.1
var hi_freq = FREQUENCY + 0.05
var random_range
var time = 0.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	random_range = randf_range(low_freq, hi_freq)
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	time += delta
	environment.fog_depth_curve = sin(time * random_range) * AMPLITUDE + 0.15
	#environment.fog_depth_begin = sin(time * 2) * 2 + 2
