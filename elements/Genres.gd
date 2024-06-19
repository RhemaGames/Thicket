extends GridContainer
var gbutton = preload("res://elements/GenreButton.tscn")
# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var OpenSeed
var Thicket 
var Music
# warning-ignore:unused_signal
signal loadup()
func _ready():
	OpenSeed = get_node("/root/OpenSeed")
	Thicket = get_node("/root/Thicket")
	#genre_load()
	pass # Replace with function body.


func genre_load():
	if get_tree().get_root().get_child(2).name == "Loader":
		Music = get_tree().get_root().get_child(2).get_node("MainWindow").get_node("WindowContainer").get_node("Music")
	else:
		Music = get_tree().get_root().get_node("MainWindow").get_node("WindowContainer").get_node("Music")
		
	var current_count = get_child_count() - 1
	
	while current_count >= 0:
		remove_child(get_child(current_count))
		current_count -= 1
	Thicket.genres.sort()
	if len(Thicket.genres) == 0:
		print("No Local Genres")
		var list = OpenSeed.get_audio("genres")
		if list:
			Thicket.genres = list
		Thicket.genres.sort()
	for genre in Thicket.genres:
		var g = gbutton.instantiate()
		g.text = genre["name"]
		g.connect("pressed", Callable(get_parent().get_parent().get_parent().get_parent(), "_on_g_pressed").bind(genre["name"))
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
	#var from_server = OpenSeed.get_from_socket('{"act":"genres","appID":"'+str(OpenSeed.appId)+'","devID":"'+str(OpenSeed.devId)+'"}')
	Thicket.genres.sort()
	var from_local = Thicket.genres
	return from_local
	
func get_genre(_genre):
	var list = ""
	
	return list

func _on_Genres_loadup():
	genre_load()
	pass # Replace with function body.
