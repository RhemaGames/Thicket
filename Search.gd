extends Control

var songlisting = preload("res://elements/songListing.tscn")
var list = []
signal clear_search()
# warning-ignore:unused_signal
signal go(artist)
signal update_playlist(list)
# warning-ignore:unused_signal
signal play_now(track)

var OpenSeed
var Thicket

func _ready():
	OpenSeed = get_node("/root/OpenSeed")
	Thicket = get_node("/root/Thicket")
	
	$newArtist.hide()
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
# warning-ignore:unused_signal
signal clear_highlight(track)

func _on_search_text_entered(new_text):
	$AnimationPlayer.play("searching")
	$Banner.emit_signal("retrieve",new_text)
	var list = get_parent().get_music(new_text)
	if len(list) >= 1:
		$newArtist.hide()
		$doublePaneView.artist = new_text
		emit_signal("update_playlist",$doublePaneView.create_list(list))
		$doublePaneView.show()
	else:
		$doublePaneView.hide()
		$newArtist.show()
		OpenSeed.get_from_socket('{"act":"artist_search","appPub":"'+str(OpenSeed.appPub)+'","devPub":"'+str(OpenSeed.devPub)+'","author":"'+new_text+'"}')
	
func _input(event):
	if event.is_action_pressed("ui_cancel"):
		emit_signal("clear_search")
		
		
		
func create_list(songarray):
	clear_list()
# warning-ignore:unused_variable
#	var height = 0
	var num = 0
	for listitem in songarray:
		
		var thesong = songlisting.instance()
		listitem.replace("'s","20%s")
		var listing = listitem.split("', '")
		if len(listing) == 16 or len(listing) == 17 or len(listing) == 18:
			Thicket.local_knowledge_add("audio",listitem)
			thesong.image = listing[3]
			thesong.title = listing[1].replace("20%s","'s")
			thesong.post  = listing[2]
			if len(listing[0].split("'")) > 1:
				thesong.artist = listing[0].split("'")[1]
			else:
				thesong.artist = listing[0].split("(")[1]
				
			thesong.fileName = listing[4].split("',")[0]
			thesong.tracknum = num
			$listView/list.add_child(thesong)
		
		if len(listing) == 13 or len(listing) == 14 or len(listing) == 15:
			Thicket.local_knowledge_add("audio",listitem)
			thesong.image = listing[3]
			thesong.title = listing[1].replace("20%s","'s")
			thesong.post  = listing[2]
			if len(listing[0].split("'")) > 1:
				thesong.artist = listing[0].split("'")[1]
			else:
				thesong.artist = listing[0].split("(")[1]
			thesong.fileName = listing[4].split("',")[0]
			thesong.tracknum = num
			$listView/list.add_child(thesong)
			
		if len(listing) == 11 or len(listing) == 12:
			Thicket.local_knowledge_add("audio",listitem)
			thesong.image = listing[3]
			thesong.title = listing[1].replace("20%s","'s")
			thesong.post  = listing[2]
			if len(listing[0].split("'")) > 1:
				thesong.artist = listing[0].split("'")[1]
			else:
				thesong.artist = listing[0].split("(")[1]
			thesong.fileName = listing[4].split("',")[0]
			thesong.tracknum = num
			$listView/list.add_child(thesong)
			
		if len(listing) == 10 :
			Thicket.local_knowledge_add("audio",listitem)
			thesong.image = listing[3].split("'")[0]
			thesong.title = listing[1].replace("20%s","'s")
			thesong.post  = listing[2]
			if len(listing[0].split("'")) > 1:
				thesong.artist = listing[0].split("'")[1]
			else:
				thesong.artist = listing[0].split("(")[1]
			if len(listing[4].split(",")) > 1:
				thesong.fileName = listing[4].split("',")[0]
			else:
				thesong.fileName = listing[4]
			thesong.tracknum = num
			$listView/list.add_child(thesong)
# warning-ignore:return_value_discarded
		if len(listing) > 3:
			list.append([thesong.fileName,thesong.artist,thesong.title,thesong.image,thesong.post])
			num +=1
		connect("clear_highlight",thesong,"_clear_highlight")
		thesong.connect("clear_highlight",self,"_clear_highlight")	
		thesong.connect("play",get_parent(),"_on_Music_play")
		thesong.connect("play_now",get_parent(),"_on_play_now")
		#thesong.connect("postview",$HSplitContainer/MusicInfo,"_on_MusicInfo_postview")
	emit_signal("update_playlist",list)
	get_parent().genre_load()
	
func clear_list():
	list = []
	var clear = $listView/list.get_child_count() - 1
	while clear >= 0:
		$listView/list.remove_child($listView/list.get_child(clear))
		clear -= 1
		
func _on_list_sort_children():
	$listView.queue_sort()
	pass # Replace with function body.

func _on_Search_clear_search():
	#clear_list()
	hide()
	$AnimationPlayer.play_backwards("searching")
	$Banner.hide()
	#$listView.hide()
	$doublePaneView.hide()
	$search.text = ""
	$newArtist.hide()
	pass # Replace with function body.
	
func _clear_highlight(track):
	self.emit_signal("clear_highlight",track)


func _on_Search_go(artist):
	$AnimationPlayer.play("searching")
	$Banner.emit_signal("retrieve",artist)
	var _list = get_parent().get_music(artist)
	$doublePaneView.artist = artist
	emit_signal("update_playlist",$doublePaneView.create_list(_list))
	$doublePaneView.show()

