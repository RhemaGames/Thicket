extends TabBar
var songlisting = preload("res://elements/MusicBoxMedium.tscn")
var currentList
var Thicket
var OpenSeed
# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var track_list = []


# Called when the node enters the scene tree for the first time.
func _ready():
	Thicket = get_node("/root/Thicket")
	OpenSeed = get_node("/root/OpenSeed")
	currentList = $HBoxContainer/VBoxContainer/Tracks/VBoxContainer
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
func loadUp(user):
	var num = 0
	for t in Thicket.tracks:
		if t["author"] == user:
			var song = songlisting.instantiate()
			track_list.append(t)
			song.title = t["title"]
			song.artist = t["author"]
			song.post = t["post"]
			song.track = t["ogg"]
			#song.img = t["img"]
			song.connect("info", Callable(self, "display_info"))
			currentList.add_child(song)
			
			if num == 0:
				display_info([t["ogg"],t["author"],t["title"],"",t["post"]])
			num += 1
	#print(track_list)

func display_info(data):	
	$HBoxContainer/Info/VBoxContainer/Post.emit_signal("show_post",data)


