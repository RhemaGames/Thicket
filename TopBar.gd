extends Panel
var Thicket
var OpenSeed
var MainWindow
# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var profile_name
var color = Color(1.0,1.0,1.0)
# Called when the node enters the scene tree for the first time.
func _ready():
	Thicket = get_node("/root/Thicket")
	OpenSeed = get_node("/root/OpenSeed")
	MainWindow = get_node("/root/MainWindow")
	MainWindow.connect("loading_complete", Callable(self, "_onloading_complete"))
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
func _onloading_complete():
	var pname = OpenSeed.loadUserProfile(OpenSeed.username)
	if !pname:
		$HBoxContainer2/Main.text = OpenSeed.username
	else:
		$HBoxContainer2/Main.text = pname
