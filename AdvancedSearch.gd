extends Control
var Thicket
var OpenSeed

var Artist = preload("res://elements/MusicBoxLarge.tscn")
var Track = preload("res://elements/MusicBoxMedium.tscn")
var List = preload("res://elements/songListing.tscn")
var User = preload("res://elements/Contact_info.tscn")

var imageFile = Image.new()
var trackTextureFile = []
var trackTextureList = []
var trackCount = 0

var artistTextureFile = []
var artistTextureList = []

var userTextureFile = []
var userTextureList = []
var userCount = 0

signal next_track(num)
signal tracks_found()

var next =0
# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var terms =""
# Called when the node enters the scene tree for the first time.
func _ready():
	Thicket = get_node("/root/Thicket")
	OpenSeed = get_node("/root/OpenSeed")
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func user_search(search):
	var reg = RegEx.new()
	reg.compile("^"+search.to_lower())
	for persons in Thicket.connections_list:
		if persons.find(":") !=-1:
			var result = reg.search(persons.to_lower().split('"')[1].split(':')[1])
			if result:
				$Panel/VBoxContainer/ScrollContainer/Main/UserSearch.show()
				var c = User.instance()
				userTextureFile.append(ImageTexture.new())
				#c.set("rect_min_size",Vector2(92,92))
				c.get_node("UserName").text = persons.split('"')[1].split(':')[1]
				c.get_node("Contact").title = persons.split('"')[1].split(':')[1]
				c.get_node("Contact").pImage = ""
				c.get_node("Contact").block = imageFile
				c.get_node("Contact").texblock = userTextureFile[userCount]
				userCount += 1
				$Panel/VBoxContainer/ScrollContainer/Main/UserSearch/VBoxContainer/GridContainer.add_child(c)
	OpenSeed.get_from_socket('{"act":"artist_search","appID":"'+str(OpenSeed.appId)+'","devID":"'+str(OpenSeed.devId)+'","author":"'+search+'"}')
			
func music_track_search(search):
	var reg = RegEx.new()
	reg.compile("^"+search.to_lower())
	if next < Thicket.tracks.size():
		var track = Thicket.tracks[next]
		var result 
		if track and track.has("title"):
			result = reg.search(str(track["title"]).to_lower())
			if result:
				var artist = track["author"]
				var title = track["title"]
				var post = track["post"]
				var img = track["img"]
				$Panel/VBoxContainer/ScrollContainer/Main/MusicSearch.show()
				$Panel/VBoxContainer/ScrollContainer/Main/MusicSearch/VBoxContainer/TrackSearch.show()
				#trackTextureFile.append(ImageTexture.new())
				var t = List.instance()
				t.title = title
				t.post = post
				t.image = img
				t.fulltrack = track
				t.artist = artist
				var minutes = float(track["duration"]) / 60
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
				
				t.duration = str(mins)+":"+str(secs)
				$Panel/VBoxContainer/ScrollContainer/Main/MusicSearch/VBoxContainer/TrackSearch/GridContainer.add_child(t)
				trackCount += 1
		next +=1
		$tracks_timeout.start()
	else:
		$tracks_timeout.stop()
		emit_signal("tracks_found")
		
func music_artist_search(search):
	var reg = RegEx.new()
	reg.compile("^"+search.to_lower())
	var count = 0
	var artists = []
	for artist in Thicket.artists:
		var result 
		result = reg.search(artist.to_lower())
		if result:
			$Panel/VBoxContainer/ScrollContainer/Main/MusicSearch.show()
			$Panel/VBoxContainer/ScrollContainer/Main/MusicSearch/VBoxContainer/ArtistsSearch.show()
			artistTextureFile.append(ImageTexture.new())
			var t = Artist.instance()
			t.title = artist
			#t.connect("search",MusicRoot,"new_artist_search")
			t.block = imageFile
			t.texblock = artistTextureFile[count]
			#t.textureList = artistTextureList
			$Panel/VBoxContainer/ScrollContainer/Main/MusicSearch/VBoxContainer/ArtistsSearch/GridContainer.add_child(t)
			#$Panel/VBoxContainer/ScrollContainer/Main/MusicSearch/VBoxContainer/ArtistsSearch/GridContainer.show()
			count += 1
	

func clear():
	$Panel/VBoxContainer/ScrollContainer/Main/MusicSearch.hide()
	$Panel/VBoxContainer/ScrollContainer/Main/MusicSearch/VBoxContainer/ArtistsSearch.hide()
	$Panel/VBoxContainer/ScrollContainer/Main/MusicSearch/VBoxContainer/TrackSearch.hide()
	$Panel/VBoxContainer/ScrollContainer/Main/UserSearch.hide()
	
	var artistGrid = $Panel/VBoxContainer/ScrollContainer/Main/MusicSearch/VBoxContainer/ArtistsSearch/GridContainer
	var artistscount = artistGrid.get_child_count() -1
	while artistscount >= 0:
		artistGrid.remove_child(artistGrid.get_child(artistscount))
		artistscount -= 1
	
	var trackGrid = $Panel/VBoxContainer/ScrollContainer/Main/MusicSearch/VBoxContainer/TrackSearch/GridContainer
	var trackcount = trackGrid.get_child_count() -1
	while trackcount >= 0:
		trackGrid.remove_child(trackGrid.get_child(trackcount))
		trackcount -= 1
	
	var userGrid = $Panel/VBoxContainer/ScrollContainer/Main/UserSearch/VBoxContainer/GridContainer
	var usercount = userGrid.get_child_count() -1
	while usercount >= 0:
		userGrid.remove_child(userGrid.get_child(usercount))
		usercount -= 1
	
	userCount = 0
	trackCount = 0
	next = 0
	$tracks_timeout.stop()

func _on_Keywords_text_entered(new_text):
	if len(new_text) > 0:
		clear()
		terms = new_text
		user_search(new_text)
		music_artist_search(new_text)
		music_track_search(new_text)

func _on_Keywords_text_changed(new_text):
	#clear()
	#terms = new_text
	#$type_timeout.start()
	pass
	


func _on_type_timeout_timeout():
	user_search(terms)
	music_artist_search(terms)
	#music_track_search(terms)
	$type_timeout.stop()
	

func _on_tracks_timeout_timeout():
	$tracks_timeout.stop()
	music_track_search(terms)
	
	pass # Replace with function body.


func _on_AdvancedSearch_tracks_found():
	#print("All tracks have been found after searching "+str(next)+" tracks")
	pass # Replace with function body.



func _on_AdvancedSearch_resized():
	if get_size().y > 0:
		$resize.start()
	pass # Replace with function body.


func _on_resize_timeout():
	$Panel/VBoxContainer/ScrollContainer.set("rect_size",Vector2(get_size().x,get_size().y))
	$resize.stop()
	pass # Replace with function body.
