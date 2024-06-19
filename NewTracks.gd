extends GridContainer

var OpenSeed
var Thicket
#var thread = Thread.new()
var newtracks = load("res://elements/MusicBoxMedium.tscn")
# Declare member variables here. Examples:
# var a = 2
# var b = "text"
# warning-ignore:unused_signal
var playlist = []
var textureList = []
var new_num = 10
var imageFile = Image.new()
var textureFile = [ImageTexture.new(),ImageTexture.new(),ImageTexture.new(),ImageTexture.new(),ImageTexture.new(),ImageTexture.new(),ImageTexture.new(),ImageTexture.new(),ImageTexture.new(),
ImageTexture.new(),ImageTexture.new(),ImageTexture.new(),ImageTexture.new(),ImageTexture.new(),ImageTexture.new()]
signal getNew()
# warning-ignore:unused_signal
signal playlist()
# Called when the node enters the scene tree for the first time.
func _ready():
	OpenSeed = get_node("/root/OpenSeed")
	Thicket = get_node("/root/Thicket")
	Thicket.connect("new_tracks_ready", Callable(self, "set_new_tracks"))
	pass # Replace with function body.
	
func new_tracks(_data):
	pass

func set_new_tracks():
	playlist = []
	var list = Thicket.new_tracks
	var count = 0
	if get_child_count() < new_num:
		for track in list:
			if track:
				var NewTrack = newtracks.instantiate()
				var artist = track["author"]
				var title = track["title"]
				var post = track["post"]
				var img = track["img"]
				if count < new_num:
					NewTrack.title = title
					NewTrack.artist = artist
					NewTrack.img = img
					NewTrack.block = imageFile
					NewTrack.post = post
					NewTrack.texblock = textureFile[count]
					NewTrack.track = track["ogg"]
					NewTrack.connect("play", Callable(get_parent().get_parent().get_parent().get_parent(), "play_track"))
				
					call_deferred("add_child", NewTrack)
					playlist.append(track)
			count += 1
	else:
		for track in list:
			var artist = track["author"]
			var title = track["title"]
			var post = track["post"]
			var img = track["img"]
			var instance
			if count < new_num:
				instance = get_child(count)
				instance.title = title
				instance.artist = artist
				instance.img = img
				instance.block = imageFile
				instance.post = post
				instance.texblock = textureFile[count]
				instance.track = track["ogg"]
				playlist.append(track)
			count += 1

func _on_NewTracks_playlist():
	return(playlist)

func _on_NewMusic_getNew():
	print("New_Music")
	set_new_tracks()

	
