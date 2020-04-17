extends Panel

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Cancel_pressed():
	hide()


func _on_Create_pressed():
	var title = $LineEdit.text
	if title.length() > 0:
		Thicket.local_knowledge_add("../playlists/"+title,"")
	hide()
