extends Control

var songlisting = preload("res://elements/songListing.tscn")
# Declare member variables here. Examples:
# var a = 2
# var b = "text"
# warning-ignore:unused_class_variable
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
	if get_tree().get_root().get_child(2).name == "Loader":
		MusicRoot = get_tree().get_root().get_child(2).get_node("MainWindow").get_node("WindowContainer").get_node("Music")
	else:
		MusicRoot = get_tree().get_root().get_node("MainWindow").get_node("WindowContainer").get_node("Music")
		
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func create_list(songarray):
	#$listView/list/Banner.emit_signal("retrieve",artist)
	
# warning-ignore:unused_variable
	var window_size = get_size()
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
# warning-ignore:unused_variable
	var type = "n/a"
# warning-ignore:unused_variable
	var genre = "n/a"
# warning-ignore:unused_variable
	var tags
	
	for listitem in songarray:
		if num < 1000:
			var thesong = songlisting.instance()
			#Thicket.local_knowledge_add("audio",listitem)
			if len(listitem) >= 8: 
				artist = listitem["author"]
				title = listitem["title"]
				post = listitem["post"]
				img = listitem["img"]
				ogg = listitem["ogg"]
				genre = listitem["genre"]
				tags = listitem["tags"]

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
				#if($Panel/listView/list.get_child_count() <= num):
				$Panel/listView/list.add_child(thesong)
				thesong.connect("play",MusicRoot,"_on_Music_play")
				thesong.connect("play_now",MusicRoot,"_on_play_now")
				thesong.connect("search",MusicRoot,"_on_artist_search")
				thesong.connect("postview",$MusicInfo,"_on_MusicInfo_postview")
				MusicRoot.connect("clear_highlight",thesong,"_clear_highlight")
				if title != "":
					num += 1	
					playlist.append([thesong.fileName,thesong.artist,thesong.title,thesong.image,thesong.post])
					
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


func _on_libraryView_visibility_changed():
	if visible:
		$Menu/GenreBox/ScrollContainer/Genres.emit_signal("loadup")
		
	pass # Replace with function body.
	
func _on_g_pressed(list):	
	if !MusicRoot.playing:
		MusicRoot.play_list_num = 0
	#$title.text = list
	var content = []
	for t in Thicket.tracks:
		print(t)
		if t and t["genre"] == list:
			content.append(t)
	#var content = OpenSeed.get_from_socket('{"act":"genre_json","appID":"'+str(OpenSeed.appId)+'","devID":"'+str(OpenSeed.devId)+'","genre":"'+list+'"}')
	MusicRoot.playlist = self.create_list(content)

func _on_MusicInfo_loaded():
	$AnimationPlayer.play("show_info")
	pass # Replace with function body.


func _on_LineEdit_text_changed(new_text):
	var content = []
	if len(new_text) > 0:
		for t in Thicket.tracks:
			if t and str(t).find(new_text) != -1:
				content.append(t)
		MusicRoot.playlist = create_list(content)

	pass # Replace with function body.
