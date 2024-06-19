extends Popup

var MusicRoot

signal load_game(game)
# Called when the node enters the scene tree for the first time.
func _ready():
	if get_tree().get_root().get_child(2).name == "Loader":
		MusicRoot = get_tree().get_root().get_child(2).get_node("MainWindow").get_node("WindowContainer")
	else:
		MusicRoot = get_tree().get_root().get_node("MainWindow").get_node("WindowContainer")
	pass # Replace with function body.

func _on_gameWindow_load_game(game):
	var thegame = ProjectSettings.load_resource_pack(game)
	if thegame:
		#var mw = ResourceLoader.load("res://start_screen.tscn")
		#var mw = ResourceLoader.load("res://scenes/mainMenu.tscn")
		var mw = ResourceLoader.load("res://menu.tscn")
		#var mw = ResourceLoader.load("res://Main.tscn")
		var make_window = mw.instantiate()
		make_window.thicket = true

		$SubViewport.add_child(make_window)
		popup_centered()
		
		get_window().set_size(Vector2(make_window.WIDTH,make_window.HEIGHT+40))
		#OS.set_window_always_on_top(false)
		#OS.set_borderless_window(false)
	pass # Replace with function body.


func _on_gameView_gui_input(event):
	get_child(0).emit_signal("remote_input",event)
	pass # Replace with function body.

func _unhandled_input(event):
	if visible:
		get_child(0).unhandled_input(event)

func _input(event):
	if visible:
		get_child(0).unhandled_input(event)