extends MenuButton


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	for item in ["Arcade","Shooter","First Person","Isometric","Adventure","Side-Scrolling","Simulation","Visual Novel","Horror","Atmosphereic"]:
		get_popup().add_item(item)


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
