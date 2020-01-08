extends Control

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var contact_count = 0
var textureList = []
var imageFile = Image.new()
var textureFile = []
var OpenSeed 
var Thicket 
var connection = 0
# Called when the node enters the scene tree for the first time.
func _ready():
	OpenSeed = get_node("/root/OpenSeed")
	Thicket = get_node("/root/Thicket")
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func get_newest_artist():
	var NewArtist = $music/VBoxContainer/RecentArtist/MusicBoxLarge
	textureFile.append(ImageTexture.new())
	if Thicket.new_artists:
		NewArtist.title = Thicket.new_artists[0]
	#NewArtist.connect("search",get_parent().get_parent().get_parent().get_parent(),"new_artist_search")
		NewArtist.block = imageFile
		NewArtist.texblock = textureFile[0]
		NewArtist.emit_signal("refresh")
	pass
	
func get_newest_tracks():
	$music/VBoxContainer/NewMusic.columns = 1
	$music/VBoxContainer/NewMusic.new_num = 3
	$music/VBoxContainer/NewMusic.emit_signal("getNew")
	
func _on_DashBoard_visibility_changed():
	if visible:
		print("Hope has arrived, because I am here")
		get_newest_artist()
		get_newest_tracks()
		
