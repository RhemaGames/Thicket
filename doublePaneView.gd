extends HSplitContainer
var songlisting = preload("res://elements/songListing.tscn")
# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var artist = ""
var playlist = []
var MusicRoot
# warning-ignore:unused_signal
signal create_list(list)
# warning-ignore:unused_signal
signal get_playlist()
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func create_list(songarray):
	#$listView/list/Banner.emit_signal("retrieve",artist)
	
	if get_tree().get_root().get_child(0).name == "Loader":
		MusicRoot = get_tree().get_root().get_child(0).get_node("MainWindow").get_node("WindowContainer").get_node("Music")
	else:
		MusicRoot = get_tree().get_root().get_node("MainWindow").get_node("WindowContainer").get_node("Music")
		
	var window_size = get_size()
	set_split_offset(window_size.x / 4)
	MusicRoot.connect("resized",self,"on_resize")
	
	clear_list()
	playlist = []
# warning-ignore:unused_variable
	var height = 0
	var num = 0
	var artist
	var title
	var post
	var img
	var ogg
	var type = "n/a"
	var genre = "n/a"
	var tags
	
	for listitem in songarray:
		var thesong = songlisting.instance()
		var track = listitem.split(', "')
		$Thicket.local_knowledge_add("audio",listitem)
		if len(track) >= 8: 
			artist = track[0].split(": ")[1].split('"')[1]
			title = track[1].split(": ")[1].trim_prefix('"').trim_suffix('"').replace("\\"," ")
			post = track[2].split(": ")[1].split('"')[1]
			img = track[3].split(": ")[1].split('"')[1]
			ogg = track[4].split(": ")[1].split('"')[1]
			if track[6].split(": ")[1] != "null":
				type = track[6].split(": ")[1].split('"')[1]
			if track[7].split(": ")[1] != "null":
				genre = track[7].split(": ")[1].split('"')[1]
			if track[8].split(": ")[1] != "null":
				tags = track[8].split(": ")[1].split('"')[1]
				
		elif track[0].find(",") != -1:
			var saved_track = track[0].split(", ")
			ogg = saved_track[0].trim_prefix('[')
			artist = saved_track[1]
			title = saved_track[2]
			img = saved_track[3]
			post = saved_track[4].trim_suffix(']')
			type = ""
			genre = ""
			tags = ""
			
		
		if len(track[0]) > 3: 
			thesong.image = img
			thesong.title = title
			thesong.post  = post
			thesong.artist = artist
			thesong.fileName = ogg
			thesong.tracknum = num
			thesong.fulltrack = track
			$listView/list.add_child(thesong)
			if title != "":
				num += 1	
				playlist.append([thesong.fileName,thesong.artist,thesong.title,thesong.image,thesong.post])
			
			thesong.connect("play",MusicRoot,"_on_Music_play")
			thesong.connect("play_now",MusicRoot,"_on_play_now")
			thesong.connect("search",MusicRoot,"_on_artist_search")
			thesong.connect("postview",$MusicInfo,"_on_MusicInfo_postview")
# warning-ignore:return_value_discarded
			MusicRoot.connect("clear_highlight",thesong,"_clear_highlight")
	return(playlist)
		
func clear_list():
	playlist = []
	var clear = $listView/list.get_child_count() - 1
	while clear >= 0:
		$listView/list.remove_child($listView/list.get_child(clear))
		clear -= 1

func _on_doublePaneView_get_playlist():
	return playlist

func on_resize():
	print("detected resize")
	$resize_timer.start()
	pass

func _on_resize_timer_timeout():
	var window_size = get_size()
	if window_size.x > 0:
		print(window_size.x)
		$MusicInfo.rect_size = Vector2(400.0,window_size.y)

	$resize_timer.stop()
	pass # Replace with function body.
