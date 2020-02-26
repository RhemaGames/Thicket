extends Control
var GameBox = preload("res://elements/GameBig.tscn")
# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var OpenSeed 
var Thicket
signal launch_game(game)
# Called when the node enters the scene tree for the first time.
func _ready():
	OpenSeed = get_node("/root/OpenSeed")
	Thicket = get_node("/root/Thicket")
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func load_library():
	
	var children = $Library/PanelContainer/ScrollContainer/recent.get_child_count() -1
	while children >= 0:
		var child = $Library/PanelContainer/ScrollContainer/recent.get_child(children)
		$Library/PanelContainer/ScrollContainer/recent.remove_child(child)
		children -= 1
		
	var dir = Directory.new()
	if dir.open("user://games") == OK:
		dir.list_dir_begin(true,true)
		var thegame = dir.get_next()
		var _count = 0
		while thegame != "":
			if !dir.current_is_dir():
				var game = GameBox.instance()
				game.game = "user://games/"+thegame
				game.title = thegame.split(".pck")[0].replace("_"," ")
				$Library/PanelContainer/ScrollContainer/recent.add_child(game)
				_count += 1
			thegame = dir.get_next()

func _on_Games_visibility_changed():
	if visible:
		load_library()
	pass # Replace with function body.


func _on_Games_launch_game(game):
	var thegame = ProjectSettings.globalize_path(game)
	var args = ["--fullscreen","--main-pack",thegame]
	var runner = ProjectSettings.globalize_path("user://runners/godot_runner_linux")
	var output = []
	var _pid = OS.execute(runner,args,true,output)
	pass # Replace with function body.
