extends Control

var openseed = load("res://elements/OpenSeed.gd")
# warning-ignore:unused_class_variable
var OpenSeed = openseed.new()
var thicket = load("res://elements/Thicket.gd")
var Thicket = thicket.new()
var noimage = preload("res://Img/folder-music-symbolic.svg")
var MusicRoot
var imgfile = File.new()

var author = ""

signal postview(post,artist,img)
# Called when the node enters the scene tree for the first time.
func _ready():
	if get_tree().get_root().get_child(0).name == "Loader":
		MusicRoot = get_tree().get_root().get_child(0).get_node("MainWindow").get_node("WindowContainer").get_node("Music")
	else:
		MusicRoot = get_tree().get_root().get_node("MainWindow").get_node("WindowContainer").get_node("Music")
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _on_MusicInfo_postview(post, artist, img):
	$trackImage.set_texture(get_image(img))
	$trackpost.bbcode_enabled = true
	$trackpost.bbcode_text = track_formatter(artist,post)
	author = artist
	$buttons.show()
	pass # Replace with function body.

func track_formatter(artist,post):
	var data = Thicket.get_post(artist,post)
	var output = ""
	var lines = data.split("\n")
	for line in lines:
		if line.find("<hr>") == 0 or line.find("<br>") == 0:
			output = output + "\n"
		elif line.find("<") == -1:
			output = output + line + "\n"
	return output

func get_image(songImage):
	var Imagedata = Image.new()
	var Imagetex = ImageTexture.new()
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
		get_timage(songImage)
			
	return Imagetex

func _on_Download_pressed():
	var steemWallet = MusicRoot.get_node("../steemWallet")
	steemWallet.emit_signal("download",MusicRoot.playlist[MusicRoot.play_list_num])
	
	steemWallet.show()
	pass # Replace with function body.


func _on_Favorite_pressed():
	$Thicket.local_knowledge_add("favorite",str(MusicRoot.playlist[MusicRoot.play_list_num]))



func _on_Like_pressed():
	$Thicket.local_knowledge_add("liked",str(MusicRoot.playlist[MusicRoot.play_list_num]))
	
func get_timage(url):
		
		$HTTPRequest.set_download_file("user://cache/"+author)
		var headers = [
			"User-Agent: Pirulo/1.0 (Godot)",
			"Accept: */*"
		]
		$HTTPRequest.request(str(url),headers,false,HTTPClient.METHOD_GET)	

# warning-ignore:unused_argument
# warning-ignore:unused_argument
# warning-ignore:unused_argument
func _on_HTTPRequest_request_completed(result, response_code, headers, body):
	if response_code == 200:
		$trackImage.set_texture(get_image(author))
	pass # Replace with function body.
