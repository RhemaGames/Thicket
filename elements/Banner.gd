extends Control

var imgfile = File.new()
var MusicRoot 
var account = ""
# warning-ignore:unused_signal
signal retrieve(data)
func _ready():
	if get_tree().get_root().get_child(2).name == "Loader":
		MusicRoot = get_tree().get_root().get_child(2).get_node("MainWindow").get_node("WindowContainer").get_node("Music")
	else:
		MusicRoot = get_tree().get_root().get_node("MainWindow").get_node("WindowContainer").get_node("Music")
		
# warning-ignore:return_value_discarded
	get_parent().get_parent().connect("resized", Callable(self, "_on_Music_resized"))
	OpenSeed.connect("profiledata", Callable(self, "_account_retrieved"))
	pass 

func _on_Banner_retrieve(data):
	show()
	account = data
	OpenSeed.openSeedRequest("get_hive_account",[account])
	
	
func get_pic(img) :
	var Imagetex = ImageTexture.new()
	var Imagedata = Image.new()
	if imgfile.file_exists(img):
		imgfile.open(img, File.READ)
		var imagesize = imgfile.get_length()
		var err = Imagedata.load_jpg_from_buffer(imgfile.get_buffer(imagesize))
		if err:
			err = Imagedata.load_png_from_buffer(imgfile.get_buffer(imagesize))
		Imagetex.create_from_image(Imagedata) #,0
		imgfile.close()
		return Imagetex
	else:
		print("File not found")

func get_cover(account,image):
	$HTTPRequest.set_download_file("user://cache/"+account+"Cover")
	var headers = [
		"User-Agent: Pirulo/1.0 (Godot)",
		"Accept: */*"
	]
	$HTTPRequest.request(str(image),headers,false,HTTPClient.METHOD_GET)

# warning-ignore:unused_argument
# warning-ignore:unused_argument
# warning-ignore:unused_argument
func _on_HTTPRequest_request_completed(result, response_code, headers, body):
	if response_code == 200:
		$TextureRect.set_texture(get_pic($HTTPRequest.get_download_file()))
	pass # Replace with function body.
	
func _on_Music_resized():
	#$Timer.start()
	pass

func _on_Timer_timeout():
	var win_size = get_parent().get_parent().get_size()
	set_size(Vector2(win_size.x,36.0))
	$Timer.stop()

func _account_retrieved(data):
	if data and data[0] == account:
		if data[1]:
			var profile = data[1]
			if typeof(profile) == TYPE_DICTIONARY:
				if str(profile["profile"]) != "Not found":
					if str(profile["profile"].keys()).find("name") != -1:
						$About/Name.text = profile["profile"]["name"]
					if str(profile["profile"].keys()).find("about") != -1:
						$About.text = profile["profile"]["about"]
			
					if !imgfile.file_exists("user://cache/"+account+"Cover"):
						if str(profile["profile"].keys()).find("cover_image") != -1:
							get_cover(account,profile["profile"]["cover_image"])
					else:
						$TextureRect.set_texture(get_pic("user://cache/"+account+"Cover"))

