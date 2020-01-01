extends Control

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var rot_speed = 0.0
# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	#rot_speed = 0.01 * randf()
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
# warning-ignore:unused_argument
func _process(delta):
	var last_rotation = $circlet.get_rotation()
	$circlet.set_rotation(last_rotation + rot_speed)
	pass
