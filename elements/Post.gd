extends PanelContainer

var noimage = preload("res://Img/folder-music-symbolic.svg")

var imgfile = File.new()
var Imagedata = Image.new()
var Imagetex = ImageTexture.new()

signal show_post(data)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func track_formatter(artist,title,post):
	var data = Thicket.get_post(artist,post)
	var currentAlign = "left"
	var output = title+"\n"+data
	var lines = output.split("\n")
	var imgs = []
	var count = $VBoxContainer.get_child_count() -1 
	while count >= 0:
		$VBoxContainer.get_child(count).queue_free()
		count -= 1
	
	for line in lines:
		var format = line.split("<")
		for t in format:
			if t.find("img src") != -1:
				var imageLine = TextureRect.new()
				var imgurl = t.split('"')[1]
				var imghash = imgurl.split("/")[len(imgurl.split("/")) -1]
				
				
			elif t.find("a href") == -1:
				var textLine = Label.new()
				textLine.autowrap = true
				if t.find("center>"):
					currentAlign = "center"
				if t.find("/center>"):
					currentAlign = "left"	
				if t != "hr>" and t != "br>" and t.find("##") and t.find("center>") and t.find("/center>") and t.find("iframe") and t.find("/iframe") and t.find("/a>"):
					textLine.text = t
					match(currentAlign):
						"left":
							textLine.ALIGN_LEFT
						"center":
							textLine.ALIGN_CENTER
							
					$VBoxContainer.add_child(textLine)

	return output


func _on_Post_show_post(data):
	#$VBoxContainer/Label.text = 
	track_formatter(data[1],data[2],data[4])
	pass # Replace with function body.


func get_image(songImage):

	if imgfile.file_exists("user://cache/Img/"+songImage):
		imgfile.open("user://cache/Img/"+songImage, File.READ)
		var imagesize = imgfile.get_len()
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
						Imagetex.create_from_image(Imagedata,0)
			else:
				if str(Imagetex).split("[")[1].split(":")[0] == "ImageTexture":
					Imagetex.create_from_image(Imagedata,0)
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

func get_timage(url,port,thefile):
		var postImg = thefile
		$HTTPRequest.set_download_file("user://cache/Img/"+thefile)
		var headers = [
			"User-Agent: Pirulo/1.0 (Godot)",
			"Accept: */*"
		]
		$HTTPRequest.request("https://"+str(url)+":"+str(port)+"/ipfs/"+str(thefile),headers,false,HTTPClient.METHOD_GET)
		#$HTTPRequest.request(str(url),headers,false,HTTPClient.METHOD_GET)	
