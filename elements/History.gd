extends PanelContainer
var OpenSeed
var Thicket
var SocialRoot

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	SocialRoot = get_parent().get_parent().get_parent()
	OpenSeed = get_node("/root/OpenSeed")
	Thicket = get_node("/root/Thicket")
	#SocialRoot.get_node("history_update").start()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_history_update_timeout():
	OpenSeed.get_history()
	pass # Replace with function body.
