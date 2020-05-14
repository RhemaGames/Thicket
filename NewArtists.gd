extends HBoxContainer
var OpenSeed
var Thicket
var newartist = load("res://elements/MusicBoxLarge.tscn")
var currentList
var imageFile = Image.new()
var textureFile = [ImageTexture.new(),ImageTexture.new(),ImageTexture.new(),ImageTexture.new(),ImageTexture.new()]

# warning-ignore:unused_signal
signal getNew()

func _ready():
	OpenSeed = get_node("/root/OpenSeed")
	Thicket = get_node("/root/Thicket")
	Thicket.connect("new_artists_ready",self,"propogate_new_artists")
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

# warning-ignore:unused_argument
func get_new_artists(num):
	var newartists = Thicket.new_artists
	return newartists

func propogate_new_artists():
	var children = get_child_count() - 1
	var list = get_new_artists(7)
	if list != currentList:
		currentList = list
		while children >= 0:
			var artist = get_child(children)
			remove_child(artist)
			artist.queue_free()
			children -= 1
		if get_child_count() < 7:
			var count = 0
			for artist in list:
				var NewArtist = newartist.instance()
				NewArtist.title = artist
				NewArtist.connect("search",get_parent().get_parent().get_parent().get_parent(),"new_artist_search")
				NewArtist.block = imageFile
				NewArtist.texblock = textureFile[count]
				call_deferred("add_child", NewArtist)
				count += 1
	return 1


func _on_NewArtists_getNew():
	propogate_new_artists()

