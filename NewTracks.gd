extends GridContainer
var openseed = load("res://elements/OpenSeed.gd")
var OpenSeed = openseed.new()

var newtracks = load("res://elements/MusicBoxMedium.tscn")
# Declare member variables here. Examples:
# var a = 2
# var b = "text"
# warning-ignore:unused_signal
var playlist = []
var textureList = []
var imageFile = Image.new()
var textureFile = [ImageTexture.new(),ImageTexture.new(),ImageTexture.new(),ImageTexture.new(),ImageTexture.new(),ImageTexture.new(),ImageTexture.new(),ImageTexture.new(),ImageTexture.new()]
signal getNew()
# warning-ignore:unused_signal
signal playlist()
# Called when the node enters the scene tree for the first time.
func _ready():
	
	pass # Replace with function body.

# warning-ignore:unused_argument
func get_new_tracks(num):
	var newartists = OpenSeed.get_from_socket('{"act":"newtracks_json","appID":"'+str(OpenSeed.appId)+'","devID":"'+str(OpenSeed.devId)+'"}')
	return newartists

func set_new_tracks():
	playlist = []
	var children = get_child_count() - 1
	while children >= 0:
		var track = get_child(children)
		remove_child(track)
		track.queue_free()
		children -= 1
		
	if get_child_count() < 9:
		var list = get_new_tracks(9)
		var clean_list = list.split("}, ")
		var count = 0
		for track in clean_list:
			var thetrack = track.split("\", ")
			
			var NewTrack = newtracks.instance()
			var artist = thetrack[0].split(": ")[1].split('"')[1]
			var title = thetrack[1].split(": ")[1].trim_prefix('"').trim_suffix('"').replace("\\"," ")
			var post = ""
			if len(thetrack[2].split(": ")) == 2:
				post = thetrack[2].split(": ")[1].split('"')[1]
			var img = thetrack[3].split(": ")[1].split('"')[1]
			if count < 9:
				NewTrack.title = title
				NewTrack.artist = artist
				NewTrack.img = img
				NewTrack.block = imageFile
				NewTrack.post = post
				NewTrack.texblock = textureFile[count]
				NewTrack.track = thetrack[4].split(": ")[1].split('"')[1]
				NewTrack.connect("play",get_parent().get_parent().get_parent().get_parent(),"play_track")
				add_child(NewTrack)
				playlist.append(track)
			count += 1

func _on_NewTracks_getNew():
	set_new_tracks()
	pass # Replace with function body.


func _on_NewTracks_playlist():
	return(playlist)
