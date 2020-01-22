extends Control
# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var playing = false
var file = File.new()
var imgfile = File.new()

# Called when the node enters the scene tree for the first time.
var stopImage = preload("res://Img/media-playback-stop-symbolic.svg")
var startImage = preload("res://Img/media-playback-start-symbolic.svg")
# warning-ignore:unused_class_variable
var songlisting = preload("res://elements/songListing.tscn")
var gbutton = preload("res://elements/GenreButton.tscn")

var noimage = preload("res://Img/folder-music-symbolic.svg")
# warning-ignore:unused_class_variable
var queue = ""
var OpenSeed 
var Thicket
var MusicBar1
var playlist = []
var play_list_num = 0


# warning-ignore:unused_signal
#signal play(filename,artist,song,image)
signal play(num)
# warning-ignore:unused_signal
signal play_now(num)
signal clear_highlight(track)

signal download()
signal download_complete()

signal show(area)

func _ready():
	OpenSeed = get_node("/root/OpenSeed")
	Thicket = get_node("/root/Thicket")
	MusicBar1 = get_tree().get_root().get_node("MainWindow/Navi/MusicBar")
	MusicBar1.connect("play_pressed",self,"_on_play_pressed") 
	MusicBar1.connect("next_track",self,"_on_nexttrack_pressed")
	MusicBar1.connect("previous_track",self,"_on_lasttrack_pressed")
	pass # Replace with function body.

# warning-ignore:unused_argument
func _process(delta):
	if playing: 
		MusicBar1.emit_signal("playposition",$AudioStreamPlayer.get_playback_position())
	
	if len(playlist) > 0:
		MusicBar1.emit_signal("playlist_loaded",true)

func _on_play_pressed(is_playing):
	if playlist:
		if is_playing == true:
			music_play()
			playing = true
		else: 
			$AudioStreamPlayer.stop()
			playing = false
		MusicBar1.emit_signal("playing",playing)

func music_play():
	var Oggy = AudioStreamOGGVorbis.new()
	MusicBar1.emit_signal("trackartist",playlist[play_list_num][1])
	MusicBar1.emit_signal("tracktitle",playlist[play_list_num][2])
	MusicBar1.emit_signal("trackart",get_image(playlist[play_list_num][3]))

	emit_signal("clear_highlight",playlist[play_list_num][0])
	var song = "user://cache/Music/"+playlist[play_list_num][0]
	if !$AllMusic.visible:
		$OptionView/MusicInfo.emit_signal("postview",playlist[play_list_num][4],playlist[play_list_num][1],playlist[play_list_num][3])
	if file.file_exists(song):
		
		file.open(song, File.READ)
		var songlength = file.get_len()
		Oggy.set_data(file.get_buffer(songlength))
		#queue = Oggy.instance()
		$AudioStreamPlayer.set_stream(Oggy)
		file.close()
		var minutes = 0
		var seconds = 0
		if str($AudioStreamPlayer.get_stream().get_length() / 60).find(".") != -1:
			minutes = str($AudioStreamPlayer.get_stream().get_length() / 60).split(".")[0]
			seconds = (int(str($AudioStreamPlayer.get_stream().get_length() / 60).split(".")[1]) * 0.1) * 60
		else:
			minutes = str($AudioStreamPlayer.get_stream().get_length() / 60)
			seconds = 0
		var seconds_string = ""
		if seconds < 10:
			seconds_string = "0"+str(seconds)
		else:
			seconds_string = str(seconds)[0]+str(seconds)[1]
		MusicBar1.emit_signal("songlength",	$AudioStreamPlayer.get_stream().get_length())
		MusicBar1.emit_signal("timeleft",minutes+":"+seconds_string)
		$AudioStreamPlayer.play()
	else:
		emit_signal("download")
		$AudioStreamPlayer.stop()
		get_song("http://142.93.27.131","8080",playlist[play_list_num][0],play_list_num)
	pass
func _on_Music_play(tracknum):
	emit_signal("clear_highlight",playlist[tracknum][0])
	play_list_num = tracknum

func _on_AudioStreamPlayer_finished():
	Thicket.playlist_save("recent",playlist[play_list_num][0])
	if len(playlist) -1 > play_list_num and playing == true:
		play_list_num += 1
		music_play()
	else:
		MusicBar1.emit_signal("playing",false)
	
# warning-ignore:unused_argument
# warning-ignore:unused_argument
# warning-ignore:unused_argument
func _on_HTTPRequest_request_completed(result, response_code, headers, body):
	if response_code == 200:
		emit_signal("download_complete")
		print("download complete song")
		var num = 0
		for song in playlist:
			var newfile =$HTTPRequest.get_download_file().split("user://cache/Music/")[1]
			if song[0] == newfile:
				play_list_num = num
				music_play()
				break
			num +=1

	
# warning-ignore:unused_argument
func get_song(url,port,thefile,tracknum):
		$HTTPRequest.set_download_file("user://cache/Music/"+thefile)
		var headers = [
			"User-Agent: Pirulo/1.0 (Godot)",
			"Accept: */*"
		]
		$HTTPRequest.request(str(url)+":"+str(port)+"/ipfs/"+str(thefile),headers,false,HTTPClient.METHOD_GET)

func _on_list_sort_children():
	$OptionView/listView.queue_sort()
	$OptionView.queue_sort()
	pass # Replace with function body.

func _on_Music_resized(): 
	$Timer.start()
	pass # Replace with function body.

func _on_Timer_timeout():
	#var _window_size = get_size()
	#$OptionView.set_split_offset(window_size.x / 4)
	$Timer.stop()

func get_image(songImage):
	var Imagetex = ImageTexture.new()
	var Imagedata = Image.new()
	if imgfile.file_exists("user://cache/Img/"+songImage):
		imgfile.open("user://cache/Img/"+songImage, File.READ)
		var imagesize = imgfile.get_len()
		var err = Imagedata.load_jpg_from_buffer(imgfile.get_buffer(imagesize))
		if err:
			err = Imagedata.load_png_from_buffer(imgfile.get_buffer(imagesize))
			if err:
				Imagetex = noimage
			else:
				Imagetex.create_from_image(Imagedata,0)
				imgfile.close()
		else:
			Imagetex.create_from_image(Imagedata,0)
			imgfile.close()
	else:
		Imagetex = noimage
			
		
		
	return Imagetex


func get_curated_music(type):
	#var list = OpenSeed.get_from_socket('{"act":"music_json","appID":"'+str(OpenSeed.appId)+'","devID":"'+str(OpenSeed.devId)+'","curator":"'+type+'"}')
	var list = Thicket.tracks
	return list

func get_music(type):
	var list = []
	match(type):
		"all":
			list = Thicket.tracks
		"favorites":
			list = "favorites"
		"liked":
			list = OpenSeed.get_from_socket('{"act":"music_json","appID":"'+str(OpenSeed.appId)+'","devID":"'+str(OpenSeed.devId)+'","curator":"'+OpenSeed.steem+'"}')
		_:
			for t in Thicket.tracks:
				if t and t["author"] == type:
					list.append(t)
			

	return list
	
# Menu Buttons

func _on_allMusic_pressed():
	$title.text = "Music Deck"	
	$OptionView.hide()
	$ArtistView.hide()
	$AllArtists.hide()
	$libraryView.hide()
	$Search.hide()
	$AllMusic.show()
	if !playing:
		play_list_num = 0
	
func _on_all_pressed():
	$title.text = "All Music"
	var content = []
	for t in Thicket.tracks:
		if t:
			content.append(t)
	playlist = $libraryView.create_list(content)
	$AllMusic.hide()
	$AllArtists.hide()
	$OptionView.hide()
	$libraryView.show()
	$Search.hide()
	if !playing:
		play_list_num = 0
	pass # Replace with function body.

func load_playlist(list_name):
	if !playing:
		play_list_num = 0
	$title.text = list_name
	var file = File.new()
	if file.file_exists("user://playlists/"+list_name+".dat"):
		file.open("user://playlists/"+list_name+".dat", File.READ)
		var redict = []
		var content = file.get_as_text().split(", \n")
		for t in content:
			if len(t) > 10:
				redict.append(parse_json(t))
		file.close()
		playlist = $OptionView.create_list(redict)
		$Search.hide()
		$AllArtists.hide()
		$AllMusic.hide()
		$OptionView.show()

func _on_likes_pressed():
	if !playing:
		play_list_num = 0
	$title.text = "Liked"
	var file = File.new()
	if file.file_exists("user://database/liked.dat"):
		file.open("user://database/liked.dat", File.READ)
		var redict = []
		var content = file.get_as_text().split(", \n")
		for t in content:
			if len(t) > 10:
				redict.append(parse_json(t))
		file.close()
		playlist = $OptionView.create_list(redict)
		$Search.hide()
		$AllArtists.hide()
		$AllMusic.hide()
		$OptionView.show()

func _on_favorites_pressed():
	if !playing:
		play_list_num = 0
	$title.text = "Favorites"
	var file = File.new()
	if file.file_exists("user://database/favorite.dat"):
		file.open("user://database/favorite.dat", File.READ)
		var redict = []
		var content = file.get_as_text().split(", \n")
		for t in content:
			if len(t) > 10:
				redict.append(parse_json(t))
		file.close()
		playlist = $OptionView.create_list(redict)
		$AllMusic.hide()
		$AllArtists.hide()
		$Search.hide()
		$OptionView.show()
	
func _on_helpiecake_pressed():
	if !playing:
		play_list_num = 0
	$title.text = "Helpie Cake"	
	var songlist = get_curated_music("helpiecake")
	$AllMusic.hide()
	$ArtistView.hide()
	$AllArtists.hide()
	$Search.hide()
	$OptionView.show()
	$libraryView.hide()
	$OptionView/MusicInfo.emit_signal("postview","would-you-like-to-have-some-cake","helpie","https://steemitimages.com/0x0/https://files.steempeak.com/file/steempeak/paintingangels/nRR4QXAt-helpiecakegirl2.jpg")
	#https://steempeak.com/helpie/@helpie/would-you-like-to-have-some-cake
	playlist = $OptionView.create_list(str(songlist).split("}, "))

func _on_curie_pressed():
	if !playing:
		play_list_num = 0
	$title.text = "C-Squared"	
	var songlist = get_curated_music("c-squared")
	$AllMusic.hide()
	$ArtistView.hide()
	$AllArtists.hide()
	$Search.hide()
	$OptionView.show()
	$libraryView.hide()
	$OptionView/MusicInfo.emit_signal("postview","witness-and-community-update-for-c-squared-january-23-2019","c-cubed","https://steemitimages.com/0x0/https://i.postimg.cc/25MsJ1dS/image.png")
	playlist = $OptionView.create_list(str(songlist).split("}, "))


# Search functions

func _on_SearchButton_pressed():
	if $Search.visible:
		$Search.emit_signal("clear_search")
	else:
		$Search.show()
		$AllArtists.hide()
		$OptionView.hide()
		$libraryView.hide()
		$ArtistView.hide()
		$AllMusic.hide()
	

func _on_artist_search(artist):
	$AllMusic.hide()
	$Search/search.text = artist
	$Search.show()
	$AllArtists.hide()
	$OptionView.hide()
	$libraryView.hide()
	$ArtistView.hide()
	$AllArtists.hide()
	$Search.emit_signal("go",artist)
	
func _on_lasttrack_pressed():
	if play_list_num > 0:
		$AudioStreamPlayer.stop()
		play_list_num -=1
		playing = true
		music_play()

func _on_nexttrack_pressed():
	if play_list_num+1 <= len(playlist) -1:
		$AudioStreamPlayer.stop()
		play_list_num +=1
		playing = true
		music_play()

func _on_Search_update_playlist(list):
	play_list_num = 0
	playlist = list

	
func get_all_music():
# warning-ignore:unused_variable
	var dir = Directory.new()
	
func _on_play_now(track):
	$AudioStreamPlayer.stop()
	play_list_num = track
	playing = true
	music_play()
	MusicBar1.emit_signal("playing",playing)
	
func new_artist_search(artist):
	var redict = []
	var songlist = get_music(artist)
	
	$ArtistView/Banner.emit_signal("retrieve",artist)
	for t in songlist:
		redict.append(t)
	playlist = $ArtistView/doublePaneView.create_list(redict)
	$ArtistView.show()
	$AllArtists.hide()
	$AllMusic.hide()
	$libraryView.hide()
	$Search.hide()
	
func _on_g_pressed(list):
	if !playing:
		play_list_num = 0
	
	$title.text = list
	var content = []
	for t in Thicket.tracks:
		if t and t["genre"] == list:
			content.append(t)
	#var content = OpenSeed.get_from_socket('{"act":"genre_json","appID":"'+str(OpenSeed.appId)+'","devID":"'+str(OpenSeed.devId)+'","genre":"'+list+'"}')
	playlist = $OptionView.create_list(content)
	$AllMusic.hide()
	$AllArtists.hide()
	$OptionView.show()
	$libraryView.hide()
	$Search.hide()

func _on_recent_pressed():
	if !playing:
		play_list_num = 0
	
	$title.text = "recent"
	var file = File.new()
	file.open("user://database/recent.dat", File.READ)
	var redict = []
	var content = file.get_as_text().split(", \n")
	for t in content:
		if len(t) > 10:
			redict.append(parse_json(t))
	file.close()
	playlist = $OptionView.create_list(redict)
	$AllMusic.hide()
	$AllArtists.hide()
	$OptionView.show()
	$libraryView.hide()
	$Search.hide()

func play_track(track):
	playlist = []
	playlist.append(track)
	play_list_num = 0
	playing = true
	MusicBar1.emit_signal("playing",playing)
	music_play()




func _on_Music_download():
	MusicBar1.emit_signal("wait","show")


func _on_Music_download_complete():
	MusicBar1.emit_signal("wait","hide")


func _on_Music_visibility_changed():
	if visible:
		get_all_music()
		#genre_load()
		$title.text = "Music Deck"	





func _on_Music_show(area):
	match(area):
		"md":
			_on_allMusic_pressed()
		"recent":
			_on_recent_pressed()
		"library":
			_on_all_pressed()
		"search":
			_on_SearchButton_pressed()
	pass # Replace with function body.
