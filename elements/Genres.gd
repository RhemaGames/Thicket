extends GridContainer
var gbutton = preload("res://elements/GenreButton.tscn")
# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var Music
func _ready():
	genre_load()
	pass # Replace with function body.


func genre_load():
	if get_tree().get_root().get_child(0).name == "Loader":
		Music = get_tree().get_root().get_child(0).get_node("MainWindow").get_node("WindowContainer").get_node("Music")
	else:
		Music = get_tree().get_root().get_node("MainWindow").get_node("WindowContainer").get_node("Music")
		
	var current_count = get_child_count() - 1
	
	while current_count >= 3:
		remove_child(get_child(current_count))
		current_count -= 1
	
	for genre in get_genres().split("),"):
		var g = gbutton.instance()
		g.text = genre.split("'")[1]
		g.connect("pressed",Music,"_on_g_pressed",[genre.split("'")[1]])
		add_child(g)
	#var dir = Directory.new()
	#if dir.open("user://database/") == OK:
	#	dir.list_dir_begin(true,true)
	#	var genres = dir.get_next()
	#	while genres != "":
	#		if genres != "audio.dat" and genres != "recent.dat":
	#			var g = gbutton.instance()
	#			g.text = genres.split(".")[0]
	#			g.connect("pressed",Music,"_on_g_pressed",[genres.split(".")[0]])
	#			add_child(g)
	#		genres = dir.get_next()
	
	pass

func get_genres():
	var from_server = $OpenSeed.get_from_socket('{"act":"genres","appID":"'+str($OpenSeed.appId)+'","devID":"'+str($OpenSeed.devId)+'"}')
	return from_server
	
func get_genre(genre):
	var list = ""
	
	return list