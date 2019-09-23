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

var playlist = []
var play_list_num = 0

# warning-ignore:unused_signal
#signal play(filename,artist,song,image)
signal play(num)
# warning-ignore:unused_signal
signal play_now(num)
signal clear_highlight(track)

func _ready():
	get_all_music()
	#genre_load()
	$title.text = "Music Deck"	
	pass # Replace with function body.

# warning-ignore:unused_argument
func _process(delta):
	if playing: 
		$MusicBar/songProgress.value = $AudioStreamPlayer.get_playback_position()

func _on_play_pressed():
	if playlist:
		if playing == false:
			music_play()
			$MusicBar/HBoxContainer/play.set_button_icon(stopImage)
			playing = true
		else: 
			$AudioStreamPlayer.stop()
			$MusicBar/HBoxContainer/play.set_button_icon(startImage)
			playing = false
			$MusicBar/playing.hide()

func music_play():
	var Oggy = AudioStreamOGGVorbis.new()
	$MusicBar/playing/artist.text = playlist[play_list_num][1]
	$MusicBar/playing/title.text = playlist[play_list_num][2]
	$MusicBar/playing.set_texture(get_image(playlist[play_list_num][3]))
	emit_signal("clear_highlight",playlist[play_list_num][0])
	var song = "user://cache/"+playlist[play_list_num][0]
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
			
		$MusicBar/songProgress.max_value = $AudioStreamPlayer.get_stream().get_length()
		$MusicBar/songProgress/left.text = minutes+":"+seconds_string
		$AudioStreamPlayer.play()
		$MusicBar/playing.show()
	else:
		$AudioStreamPlayer.stop()
		get_song("http://142.93.27.131","8080",playlist[play_list_num][0],play_list_num)
		$MusicBar/playing.hide()
	
		
	pass
func _on_Music_play(tracknum):
	emit_signal("clear_highlight",playlist[tracknum][0])
	play_list_num = tracknum

func _on_AudioStreamPlayer_finished():
	$Thicket.playlist_save("recent",playlist[play_list_num])
	if len(playlist) -1 > play_list_num:
		play_list_num += 1
		music_play()
	else:
		$MusicBar/HBoxContainer/play.set_button_icon(startImage)
	
# warning-ignore:unused_argument
# warning-ignore:unused_argument
# warning-ignore:unused_argument
func _on_HTTPRequest_request_completed(result, response_code, headers, body):
	if response_code == 200:
		print("download complete song")
		var num = 0
		for song in playlist:
			var newfile =$HTTPRequest.get_download_file().split("user://cache/")[1]
			if song[0] == newfile:
				play_list_num = num
				music_play()
				break
			num +=1

	
# warning-ignore:unused_argument
func get_song(url,port,thefile,tracknum):
		$HTTPRequest.set_download_file("user://cache/"+thefile)
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
	var window_size = get_size()
	$OptionView.set_split_offset(window_size.x / 4)
	$Timer.stop()

func get_image(songImage):
	var Imagetex = ImageTexture.new()
	var Imagedata = Image.new()
	if imgfile.file_exists("user://cache/"+songImage):
		imgfile.open("user://cache/"+songImage, File.READ)
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
	var list = $OpenSeed.get_from_socket('{"act":"music_json","appID":"'+str($OpenSeed.appId)+'","devID":"'+str($OpenSeed.devId)+'","curator":"'+type+'"}')
	return list

func get_music(type):
	var list = ""
	match(type):
		"all":
			list = "test"
		"favorites":
			list = "favorites"
		"liked":
			list = $OpenSeed.get_from_socket('{"act":"music_json","appID":"'+str($OpenSeed.appId)+'","devID":"'+str($OpenSeed.devId)+'","curator":"'+$OpenSeed.steem+'"}')
		_:
			list = $OpenSeed.get_from_socket('{"act":"getArtistTracks","appID":"'+str($OpenSeed.appId)+'","devID":"'+str($OpenSeed.devId)+'","author":"'+type+'"}')
	return list
	
# Menu Buttons

func _on_allMusic_pressed():
	$title.text = "Music Deck"	
	$OptionView.hide()
	$ArtistView.hide()
	$AllArtists.hide()
	$Search.hide()
	$AllMusic.show()

func load_playlist(list_name):
	$title.text = list_name
	var file = File.new()
	if file.file_exists("user://playlists/"+list_name+".dat"):
		file.open("user://playlists/"+list_name+".dat", File.READ)
		var content = file.get_as_text()
		playlist = $OptionView.create_list(content.split(", \n"))
		file.close()
		$Search.hide()
		$AllArtists.hide()
		$AllMusic.hide()
		$OptionView.show()

func _on_likes_pressed():
	$title.text = "Liked"
	var file = File.new()
	if file.file_exists("user://database/liked.dat"):
		file.open("user://database/liked.dat", File.READ)
		var content = file.get_as_text()
		playlist = $OptionView.create_list(content.split(", \n"))
		file.close()
		$Search.hide()
		$AllArtists.hide()
		$AllMusic.hide()
		$OptionView.show()

func _on_favorites_pressed():
	$title.text = "Favorites"
	var file = File.new()
	if file.file_exists("user://database/favorite.dat"):
		file.open("user://database/favorite.dat", File.READ)
		var content = file.get_as_text()
		file.close()
		playlist = $OptionView.create_list(content.split(", \n"))
		$AllMusic.hide()
		$AllArtists.hide()
		$Search.hide()
		$OptionView.show()
	
func _on_helpiecake_pressed():
	$title.text = "Helpie Cake"	
	var songlist = get_curated_music("helpiecake")
	$AllMusic.hide()
	$ArtistView.hide()
	$AllArtists.hide()
	$Search.hide()
	$OptionView.show()
	$OptionView/MusicInfo.emit_signal("postview","would-you-like-to-have-some-cake","helpie","https://steemitimages.com/0x0/https://files.steempeak.com/file/steempeak/paintingangels/nRR4QXAt-helpiecakegirl2.jpg")
	#https://steempeak.com/helpie/@helpie/would-you-like-to-have-some-cake
	playlist = $OptionView.create_list(str(songlist).split("}, "))

func _on_curie_pressed():
	$title.text = "C-Squared"	
	var songlist = get_curated_music("c-squared")
	$AllMusic.hide()
	$ArtistView.hide()
	$AllArtists.hide()
	$Search.hide()
	$OptionView.show()
	$OptionView/MusicInfo.emit_signal("postview","witness-and-community-update-for-c-squared-january-23-2019","c-cubed","https://steemitimages.com/0x0/https://i.postimg.cc/25MsJ1dS/image.png")
	playlist = $OptionView.create_list(str(songlist).split("}, "))


# Search functions

func _on_SearchButton_pressed():
	if $Search.visible:
		$Search.emit_signal("clear_search")
		$SearchButton.text = "Search"
	else:
		$Search.show()
		$SearchButton.text = "Close"

func _on_artist_search(artist):
	$Search/search.text = artist
	$Search.show()
	$AllArtists.hide()
	$SearchButton.text = "Close"
	$Search.emit_signal("go",artist)
	
func _on_lasttrack_pressed():
	if play_list_num > 0:
		$AudioStreamPlayer.stop()
		play_list_num -=1
		playing = true
		music_play()
		#$AudioStreamPlayer.play()

func _on_nexttrack_pressed():
	if play_list_num+1 <= len(playlist) -1:
		$AudioStreamPlayer.stop()
		play_list_num +=1
		playing = true
		music_play()
		#$AudioStreamPlayer.play()

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
	$MusicBar/HBoxContainer/play.set_button_icon(stopImage)
	
func new_artist_search(artist):
	
	var songlist = get_music(artist)
	$ArtistView/Container/Banner.emit_signal("retrieve",artist)
	playlist = $ArtistView/Container/doublePaneView.create_list(str(songlist).split("}, "))
	$ArtistView.show()
	$AllArtists.hide()
	#$SearchButton.text = "Close"
	$AllMusic.hide()
	
func _on_g_pressed(list):
	$title.text = list
	var content = $OpenSeed.get_from_socket('{"act":"genre_json","appID":"'+str($OpenSeed.appId)+'","devID":"'+str($OpenSeed.devId)+'","genre":"'+list+'"}')
	playlist = $OptionView.create_list(content.split("}, "))
	$AllMusic.hide()
	$AllArtists.hide()
	$OptionView.show()

func _on_recent_pressed():
	$title.text = "recent"
	var file = File.new()
	file.open("user://database/recent.dat", File.READ)
	var content = file.get_as_text().split(", \n")
	file.close()
	playlist = $OptionView.create_list(content)
	$AllMusic.hide()
	$AllArtists.hide()
	$OptionView.show()

func play_track(track):
	playlist = []
	playlist.append(track)
	play_list_num = 0
	playing = true
	$MusicBar/HBoxContainer/play.set_button_icon(stopImage)
	music_play()


