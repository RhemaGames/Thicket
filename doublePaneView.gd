extends HSplitContainer
var songlisting = preload("res://elements/songListing.tscn")
# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var artist = ""
var playlist = []
var MusicRoot
var Thicket 
# warning-ignore:unused_signal
signal create_list(list)
# warning-ignore:unused_signal
signal get_playlist()
# Called when the node enters the scene tree for the first time.
func _ready():
	Thicket = get_node("/root/Thicket")
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func create_list(songarray):
	#$listView/list/Banner.emit_signal("retrieve",artist)
	
	if get_tree().get_root().get_child(2).name == "Loader":
		MusicRoot = get_tree().get_root().get_child(2).get_node("MainWindow").get_node("WindowContainer").get_node("Music")
	else:
		MusicRoot = get_tree().get_root().get_node("MainWindow").get_node("WindowContainer").get_node("Music")
		
	#var window_size = get_size()
	#set_split_offset(window_size.x / 4)
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
	var _type = "n/a"
	var _genre = "n/a"
	var _tags
	
	for listitem in songarray:
		var thesong = songlisting.instance()
		#Thicket.local_knowledge_add("audio",listitem)
		if len(listitem) >= 8: 
			artist = listitem["author"]
			title = listitem["title"]
			post = listitem["post"]
			img = listitem["img"]
			ogg = listitem["ogg"]
			_genre = listitem["genre"]
			_tags = listitem["tags"]

		if len(listitem) > 3: 
			thesong.image = img
			thesong.title = title
			thesong.post  = post
			thesong.artist = artist
			thesong.fileName = ogg
			thesong.tracknum = num
			thesong.fulltrack = listitem
			if listitem["duration"]:
				var minutes = float(listitem["duration"]) / 60
				var seconds = 0
				var secs = ""
				var mins = ""
				if str(minutes).find(".") != -1:
					mins = str(minutes).split(".")[0]
					seconds = (int(str(minutes).split(".")[1]) * 0.1) * 60
				else:
					mins = str(minutes)
					seconds = 0
				if seconds < 10:
					secs = "0"+str(seconds)
				else:
					secs = str(seconds)[0]+str(seconds)[1]
				
				thesong.duration = str(mins)+":"+str(secs)
			else:
				thesong.duration = "unknown"
			#thesong.duration = listitem["duration"]
			$Panel/listView/list.add_child(thesong)
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
	var clear = $Panel/listView/list.get_child_count() - 1
	while clear >= 0:
		$Panel/listView/list.get_child(clear).queue_free()
		clear -= 1

func _on_doublePaneView_get_playlist():
	return playlist

func on_resize():
	#print("detected resize")
	#$resize_timer.start()
	pass

func _on_resize_timer_timeout():
	#var window_size = get_size()
	#if window_size.x > 0:
	#	print(window_size.x)
		#$Panel.rect_size.x = 1200
		#$MusicInfo.rect_size = Vector2(400.0,window_size.y)
	#$resize_timer.stop()
	pass # Replace with function body.
