extends Panel

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var fallback_audio = preload("res://Img/folder-music-symbolic.svg")
var title = ""
var artist = ""
var block = ""
var post = ""
var texblock = ""
var img = ""
var track = ""
var imgfile = File.new()
var textureList = []

signal play(track)
signal info(track)
# Called when the node enters the scene tree for the first time.
func _ready():
	$artist.text = artist
	$title.text = title
	set_box(img)
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func set_box(image):
	if !imgfile.file_exists("user://cache/Img/"+image):
		get_timage("http://142.93.27.131","8080",image)
		#print("No Image")
	else:
		$TextureRect.set_texture(get_image("user://cache/Img/"+image))
		textureList.append($TextureRect.get_texture())
	
func get_image(image):
	var Imagedata = block
	var Imagetex = texblock
	if imgfile.file_exists(image):
		imgfile.open(image, File.READ)
		var imagesize = imgfile.get_len()
		
		if imagesize <= 3615421:
			var buffer = imgfile.get_buffer(imagesize)
			var err = Imagedata.load_jpg_from_buffer(buffer)
			Imagedata.compress(0,0,90)
			if err !=OK:
				err = Imagedata.load_png_from_buffer(buffer)
				Imagedata.compress(0,0,90)
				if err !=OK:
					Imagetex = fallback_audio
				else:
					Imagetex.create_from_image(Imagedata,0)
			else:
				Imagetex.create_from_image(Imagedata,0)
		else:
			print(image)
			print("too big")
			print(imagesize)
			Imagetex = fallback_audio
		imgfile.close()
		return Imagetex
	
func get_timage(url,port,thefile):
	var file = File.new()
	if !file.file_exists("user://cache/Img/"+thefile):
		$HTTPRequest.set_download_file("user://cache/Img/"+thefile)
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
	pass # Replace with function body.


func _on_MusicBoxMedium_gui_input(event):
	if event is InputEventMouseButton and !event.is_doubleclick() and event.is_pressed():
		emit_signal("info",[track,artist,title,img,post])
	if event is InputEventMouseButton and event.is_doubleclick():
		emit_signal("play",[track,artist,title,img,post])
	pass # Replace with function body.
