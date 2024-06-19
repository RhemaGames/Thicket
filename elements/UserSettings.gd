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
	SocialRoot.connect("changeview", Callable(self, "change_view"))
	OpenSeed = get_node("/root/OpenSeed")
	Thicket = get_node("/root/Thicket")
	#if !SocialRoot.currentuser or SocialRoot.currentuser == OpenSeed.username:
	#	self.show()
	#else:
	#	self.hide()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func change_view(account):
	print(account)
	if account == OpenSeed.username:
		self.show()
	else:
		self.hide()
