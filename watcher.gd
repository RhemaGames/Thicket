extends Control

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	$Timer.start()
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_watcher_gui_input(event):
	print(event)
	$Timer.start()
	pass # Replace with function body.


func _on_Timer_timeout():
	print("sleep Mode")
	
	pass # Replace with function body.
