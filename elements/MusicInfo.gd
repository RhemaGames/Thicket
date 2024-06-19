extends Control

# warning-ignore:unused_class_variable
var OpenSeed 
var Thicket 
var noimage = preload("res://Img/folder-music-symbolic.svg")
var MusicRoot
var imgfile = File.new()
var Imagedata = Image.new()
var Imagetex = ImageTexture.new()

var author = ""
var thepost = ""
var postImg
var the_img
# warning-ignore:unused_signal
signal postview(post,artist,img)
signal loaded()
# Called when the node enters the scene tree for the first time.
func _ready():
	OpenSeed = get_node("/root/OpenSeed")
	Thicket = get_node("/root/Thicket")
	
	if get_tree().get_root().get_child(2).name == "Loader":
		MusicRoot = get_tree().get_root().get_child(2).get_node("MainWindow").get_node("WindowContainer").get_node("Music")
	else:
		MusicRoot = get_tree().get_root().get_node("MainWindow").get_node("WindowContainer").get_node("Music")
	pass # Replace with function body.
	OpenSeed.connect("imagestored", Callable(self, "refresh"))
	OpenSeed.connect("post", Callable(self, "post_refresh"))

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _on_MusicInfo_postview(post, artist, img):
	postImg = img
	OpenSeed.openSeedRequest("get_hive_post",[artist,post])
	OpenSeed.openSeedRequest("get_image",[img,"medium"])
	var imagehash = "No_Image_found"
	var the_img
	if imagehash != "No_Image_found":
		var fromStore = OpenSeed.get_from_image_store(imagehash)
		if !fromStore:
			the_img = OpenSeed.set_image(imagehash)
		else:
			the_img = fromStore
	$trackImage.set_texture(the_img)
	$trackpost.bbcode_enabled = true
	$trackpost.text = track_formatter(artist,post)
	author = artist
	thepost = post
	$buttons.show()
	emit_signal("loaded")
	pass # Replace with function body.

func track_formatter(artist,post):
	var data = post
	var output = ""
	if data:
		var lines = data.split("\n")
		for line in lines:
			if line.find("<hr>") == 0 or line.find("<br>") == 0:
				output = output + "\n"
			elif line.find("<") == -1:
				#if line.find("[!") and line.find("]") and line.find("!["):
				if line != "#" and line != "##" and line != "###" and line != "####":
					output = output + line + "\n"
				
	return output

func get_image(songImage):

	if imgfile.file_exists("user://cache/Img/"+songImage):
		imgfile.open("user://cache/Img/"+songImage, File.READ)
		var imagesize = imgfile.get_length()
		if imagesize <= 3554421:
			var buffer = imgfile.get_buffer(imagesize)
			var err = Imagedata.load_jpg_from_buffer(buffer)
			Imagedata.compress(0,0,90)
			if err != OK:
				err = Imagedata.load_png_from_buffer(buffer)
				Imagedata.compress(0,0,90)
				if err != OK:
					Imagetex = noimage
				else:
					if str(Imagetex).split("[")[1].split(":")[0] == "ImageTexture":
						Imagetex.create_from_image(Imagedata) #,0
			else:
				if str(Imagetex).split("[")[1].split(":")[0] == "ImageTexture":
					Imagetex.create_from_image(Imagedata) #,0
		else:
			print(songImage)
			print("too big")
			print(imagesize)
			Imagetex = noimage
		imgfile.close()
	else:
		Imagetex = noimage
		get_timage(OpenSeed.openseed,"8080",songImage)
			
	return Imagetex

func _on_Download_pressed():
	var steemWallet = MusicRoot.get_node("../steemWallet")
	steemWallet.emit_signal("download",MusicRoot.playlist[MusicRoot.play_list_num])
	
	steemWallet.show()
	pass # Replace with function body.


func _on_Favorite_pressed():
	Thicket.local_knowledge_add("favorite",str(MusicRoot.playlist[MusicRoot.play_list_num]))



func _on_Like_pressed():
	OpenSeed.openSeedRequest("send_hive_like",[OpenSeed.token,author,thepost])
	Thicket.local_knowledge_add("liked",str(MusicRoot.playlist[MusicRoot.play_list_num]))
	
func get_timage(url,port,thefile):
		postImg = thefile
		$HTTPRequest.set_download_file("user://cache/Img/"+thefile)
		var headers = [
			"User-Agent: Pirulo/1.0 (Godot)",
			"Accept: */*"
		]
		$HTTPRequest.request("https://"+str(url)+":"+str(port)+"/ipfs/"+str(thefile),headers,false,HTTPClient.METHOD_GET)
		#$HTTPRequest.request(str(url),headers,false,HTTPClient.METHOD_GET)	

# warning-ignore:unused_argument
# warning-ignore:unused_argument
# warning-ignore:unused_argument
func _on_HTTPRequest_request_completed(result, response_code, headers, body):
	if response_code == 200:
		$trackImage.set_texture(get_image(postImg))
	pass # Replace with function body.


func _on_Comment_pressed():
	print("Opening Comment dialog")
	OpenSeed.interface("comment",true,[OpenSeed.token,author,thepost,the_img])
	#MusicRoot.OpenSeed.emit_signal("comment",["test","test","test"])
	pass # Replace with function body.

func refresh(data):
	
	if data[1] != "No_Image_found" and data[0] == postImg:
		#var texbox = TextureRect.new()
		var fromStore = OpenSeed.get_from_image_store(data[1])
		if !fromStore:
			the_img = noimage
		else:
			the_img = fromStore
		$trackImage.set_texture(the_img)

func post_refresh(data):
	$trackpost.bbcode_enabled = true
	$trackpost.text = track_formatter(data["author"],data["post"])
