extends Panel

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var active = false
var bgColor = Color(0.1,1,0.5)
var textColor = Color(1,1,1)
var icon = ""
var text = "Area"
var title = ""

# Called when the node enters the scene tree for the first time.
func _ready():
	#self_modulate = bgColor
	#$area.text = text
	#$area.self_modulate = Color(1,1,1)
	self_modulate = get_parent().get_parent().bgColor
	$area.text = text
	$area.self_modulate = Color(1,1,1)
	
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
