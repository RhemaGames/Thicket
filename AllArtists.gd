extends Control

var artistView = preload("res://elements/MusicBoxLarge.tscn")
var imageFile = Image.new()
var textureFile = []
var MusicRoot

# Called when the node enters the scene tree for the first time.
func _ready():
	if get_tree().get_root().get_child(0).name == "Loader":
		MusicRoot = get_tree().get_root().get_child(0).get_node("MainWindow").get_node("WindowContainer").get_node("Music")
	else:
		MusicRoot = get_tree().get_root().get_node("MainWindow").get_node("WindowContainer").get_node("Music")
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_AllArtists_visibility_changed():
	if visible:
		get_artists()

func get_artists():
	var children = $ScrollContainer/GridContainer.get_child_count() -1
	while children >= 0:
		var child = $ScrollContainer/GridContainer.get_child(children)
		$ScrollContainer/GridContainer.remove_child(child)
		children -= 1
		
	var dir = Directory.new()
	if dir.open("user://database/artists") == OK:
		dir.list_dir_begin(true,true)
		var artist = dir.get_next()
		var count = 0
		while artist != "":
			textureFile.append(ImageTexture.new())
			#fill_info(artist)
			var g = artistView.instance()
			g.title = artist.split(".")[0]
			g.connect("search",MusicRoot,"new_artist_search")
			g.block = imageFile
			g.texblock = textureFile[count]
			$ScrollContainer/GridContainer.add_child(g)
			count += 1
			#g.connect("pressed",self,"_on_g_pressed",[playlists.split(".")[0]])
			artist = dir.get_next()

#func fill_info(artist):
	#var info = $Thicket.local_knowledge_load("artists/"+artist.split(".")[0])
	#for line in info.split(", \n"):
	#	var parsed = parse_json(line)
	#	if parsed:
	#		if parsed.keys()[0] == "ProfileName":
	#			print(parsed["ProfileName"])
	