extends Control

var artistView = preload("res://elements/MusicBoxLarge.tscn")
var imageFile = Image.new()
var textureFile = []
var MusicRoot
var thread = Thread.new()
var artist_num = 0
var Thicket
var OpenSeed

# Called when the node enters the scene tree for the first time.
func _ready():
	if get_tree().get_root().get_child(2).name == "Loader":
		MusicRoot = get_tree().get_root().get_child(2).get_node("MainWindow").get_node("WindowContainer").get_node("Music")
	else:
		MusicRoot = get_tree().get_root().get_node("MainWindow").get_node("WindowContainer").get_node("Music")
	
	Thicket = get_node("/root/Thicket")
	OpenSeed = get_node("/root/OpenSeed")
	
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_AllArtists_visibility_changed():
	if visible:
		#clear_artists()
		get_artists_new(0)
	else:
		artist_num = 0
		#thread.start(self,"get_artists_new()","_got_aritsts_new")

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

func get_artists_new(anum):
	var catalog = []
	if anum < Thicket.artists.size():
		if anum >= $ScrollContainer/GridContainer.get_child_count():
			textureFile.append(ImageTexture.new())
			var artist = Thicket.artists[anum]
			var g = artistView.instance()
			g.title = artist
			g.connect("search",MusicRoot,"new_artist_search")
			g.block = imageFile
			g.texblock = textureFile[anum]
			$ScrollContainer/GridContainer.add_child(g)
			$Timer.start()

func _on_Timer_timeout():
	$Timer.stop()
	artist_num += 1
	get_artists_new(artist_num)
	pass # Replace with function body.
	
func clear_artists():
	var children = $ScrollContainer/GridContainer.get_child_count() -1
	while children >= 0:
		var child = $ScrollContainer/GridContainer.get_child(children)
		#$ScrollContainer/GridContainer.remove_child(child)
		child.queue_free()
		children -= 1
