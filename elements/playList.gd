extends VBoxContainer
var songlisting = preload("res://elements/songListing.tscn")
# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var title = ""
var MusicRoot
# Called when the node enters the scene tree for the first time.
func _ready():
	$Controls/title.text = title
	fill_list(Thicket.playlist_load(title))
	$Timer.start()
	if get_tree().get_root().get_child(2).name == "Loader":
		MusicRoot = get_tree().get_root().get_child(2).get_node("MainWindow").get_node("WindowContainer").get_node("Music")
	else:
		MusicRoot = get_tree().get_root().get_node("MainWindow").get_node("WindowContainer").get_node("Music")
	pass # Replace with function body.

func fill_list(list):
	clear_list()
	if get_tree().get_root().get_child(2).name == "Loader":
		MusicRoot = get_tree().get_root().get_child(2).get_node("MainWindow").get_node("WindowContainer").get_node("Music")
	else:
		MusicRoot = get_tree().get_root().get_node("MainWindow").get_node("WindowContainer").get_node("Music")
	var num = 0
	if list:
		for listing in list.split(", \n"):
			if len(listing) > 3 and num <=13:
				var test_json_conv = JSON.new()
				test_json_conv.parse(listing)
				var track = test_json_conv.get_data()
				var Song = songlisting.instantiate()
				Song.image = track["img"]
				Song.title = track["title"]
				Song.post  = track["post"]
				Song.artist = track["author"]
				Song.fileName = track["ogg"]
				Song.tracknum = num
				Song.clickable = false
				#Song.connect("play",MusicRoot,"_on_Music_play")
				#Song.connect("play_now",MusicRoot,"_on_play_now")
				#Song.connect("search",MusicRoot,"_on_artist_search")
# warning-ignore:return_value_discarded
				MusicRoot.connect("clear_highlight", Callable(Song, "_clear_highlight"))
				add_child(Song)
				num +=1
		
func clear_list():
	var clear = self.get_child_count() - 1
	while clear >= 3:
		self.remove_child(self.get_child(clear))
		clear -= 1

func _on_Play_pressed():
	MusicRoot._on_recent_pressed()
	pass # Replace with function body.


func _on_Timer_timeout():
	fill_list(Thicket.playlist_load(title))
	pass # Replace with function body.
