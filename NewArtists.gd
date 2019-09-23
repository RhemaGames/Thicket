extends HBoxContainer
var openseed = load("res://elements/OpenSeed.gd")
var OpenSeed = openseed.new()

var newartist = load("res://elements/MusicBoxLarge.tscn")

var imageFile = Image.new()
var textureFile = [ImageTexture.new(),ImageTexture.new(),ImageTexture.new(),ImageTexture.new(),ImageTexture.new()]

signal getNew()

func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

# warning-ignore:unused_argument
func get_new_artists(num):
	var newartists = OpenSeed.get_from_socket('{"act":"newaccounts","appID":"'+str(OpenSeed.appId)+'","devID":"'+str(OpenSeed.devId)+'"}')
	return newartists

func propogate_new_artists():
	var children = get_child_count() - 1
	while children >= 0:
		var artist = get_child(children)
		remove_child(artist)
		artist.queue_free()
		children -= 1
	if get_child_count() < 5:
		var list = get_new_artists(5)
		var clean_list = list.split("[")[1].split("]")[0].split("),")
		var count = 0
		var thicket = get_parent().get_parent().get_parent().get_node("Thicket")
		for artist in clean_list:
			var NewArtist = newartist.instance()
			NewArtist.title = artist.split("'")[1]
			NewArtist.connect("search",get_parent().get_parent().get_parent().get_parent(),"new_artist_search")
			NewArtist.block = imageFile
			NewArtist.texblock = textureFile[count]
			add_child(NewArtist)
			count += 1


func _on_NewArtists_getNew():
	propogate_new_artists()
	pass # Replace with function body.
