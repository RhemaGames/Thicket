extends Control

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var game = ""
var title = "Title"
var company = "Company"
var GamesRoot
# Called when the node enters the scene tree for the first time.
func _ready():
	$Label.text = title
	#$Company.text = company
	if get_tree().get_root().get_child(2).name == "Loader":
		GamesRoot = get_tree().get_root().get_child(2).get_node("MainWindow").get_node("WindowContainer").get_node("Games")
		
	else:
		GamesRoot = get_tree().get_root().get_node("MainWindow").get_node("WindowContainer").get_node("Games")

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_GameBig_visibility_changed():
	pass


func _on_GameBig_gui_input(event):
	
	if event is InputEventMouseButton and Input.is_mouse_button_pressed(1):
		#var game = "user://games/Code Breakers.pck"
		#GamesRoot.get_node("gameWindow").emit_signal("load_game",game)
		GamesRoot.emit_signal("launch_game",game)
	pass # Replace with function body.


func _on_GameBig_mouse_entered():
	$AnimationPlayer.play("mouseover",0,4)
	pass # Replace with function body.


func _on_GameBig_mouse_exited():
	$AnimationPlayer.play("mouseover",0,-4,true)
	pass # Replace with function body.
