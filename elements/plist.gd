extends Control

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
signal title(name)
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_plist_title(name):
	$Control/title.text = name
	pass # Replace with function body.


func _on_plist_gui_input(event):
	
	pass # Replace with function body.
