extends Panel
var fallback_audio = preload("res://Img/folder-music-symbolic.svg")

var playlist
var thetrack

var artist
var ogg
var img
var post
var title
var type
var genre
var tags

var imgfile = File.new()
var Imagedata = Image.new()
var Imagetex = ImageTexture.new()
signal add_track(track)

func _ready():
#	load_playlists()
	pass
	
func _on_Cancel_pressed():
	hide()
	
func _on_Button_pressed():
	$Thicket.local_knowledge_add("../playlists/"+playlist,thetrack[0])
	hide()
	
func load_playlists():
	$Control/OptionButton.clear()
	
	var dir = Directory.new()
	if dir.open("user://playlists") == OK:
		dir.list_dir_begin(true,true)
		var playlist = dir.get_next()
		var count = 0
		while playlist != "":
			$Control/OptionButton.add_item(playlist.split(".")[0])
			count += 1
			playlist = dir.get_next()
	playlist = $Control/OptionButton.get_item_text(0)

func _on_OptionButton_item_selected(ID):
	playlist = $Control/OptionButton.get_item_text(ID)

func _on_PlaylistAdd_add_track(track):
	show()
	thetrack = track
	parse_track(track)
	
func parse_track(track):
	thetrack = track
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
	$title.text =title
	$artist.text = artist
	
	set_box(img)
	
	
func set_box(image):
	if !imgfile.file_exists("user://cache/"+image):
		get_timage("http://142.93.27.131","8080",image)
	else:
		$TextureRect.set_texture(get_image("user://cache/"+image))
		#get_parent().textureList.append($TextureRect.get_texture())
	
func get_image(image):

	if imgfile.file_exists(image):
		imgfile.open(image, File.READ)
		var imagesize = imgfile.get_len()
		
		if imagesize < 999999:
			var err = Imagedata.load_jpg_from_buffer(imgfile.get_buffer(imagesize))
			Imagedata.compress(0,0,75)
			if err !=OK:
				err = Imagedata.load_png_from_buffer(imgfile.get_buffer(imagesize))
				Imagedata.compress(0,0,75)
				if err !=OK:
					Imagetex = fallback_audio
				else:
					Imagetex.create_from_image(Imagedata,0)
			else:
				Imagetex.create_from_image(Imagedata,0)
		else:
			Imagetex = fallback_audio
		imgfile.close()
		return Imagetex
	
func get_timage(url,port,thefile):
	var file = File.new()
	if !file.file_exists("user://cache/"+thefile):
		$HTTPRequest.set_download_file("user://cache/"+thefile)
		var headers = [
			"User-Agent: Pirulo/1.0 (Godot)",
			"Accept: */*"
		]
		$HTTPRequest.request(str(url)+":"+str(port)+"/ipfs/"+str(thefile),headers,false,HTTPClient.METHOD_GET)	

# warning-ignore:unused_argument
# warning-ignore:unused_argument
# warning-ignore:unused_argument
func _on_HTTPRequest_request_completed(result, response_code, headers, body):
	if response_code == 200:
		$TextureRect.set_texture(get_image($HTTPRequest.get_download_file()))

func _on_PlaylistAdd_visibility_changed():
	if visible:
		load_playlists()
	
