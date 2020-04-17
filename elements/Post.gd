extends PanelContainer

var noimage = preload("res://Img/folder-music-symbolic.svg")

var imgfile = File.new()
var Imagedata = Image.new()
var Imagetex = ImageTexture.new()
var img 
var refresh
signal show_post(data)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func track_formatter(artist,title,post):
	var data = Thicket.get_post(artist,post)
#	var currentAlign = "left"
	var output = title+"\n"+data
	var lines = output.split("\n")
	
	var count = $VBoxContainer.get_child_count() -1 
	while count >= 0:
		$VBoxContainer.get_child(count).queue_free()
		$VBoxContainer.remove_child($VBoxContainer.get_child(count))
		count -= 1
	
	for line in lines:
		var format = line.split("<")
		for t in format:
			if t.find("img src") != -1:
				var imgurl = t.split('"')[1]
				var imagehash = OpenSeed.get_image(imgurl)
				if imagehash != "No_Image_found":
					var texbox = TextureRect.new()
					var fromStore = OpenSeed.get_from_image_store(imagehash)
					if !fromStore:
						img = OpenSeed.set_image(imagehash)
					else:
						img = fromStore
						
					texbox.set_texture(img)
					texbox.rect_min_size = Vector2(0.0,300.0)
					texbox.expand = true
					texbox.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
					$VBoxContainer.add_child(texbox)
				
			elif t.find("a href") == -1:
				var textLine = Label.new()
				textLine.autowrap = true
				#if t.find("center>"):
#					currentAlign = "center"
			#	if t.find("/center>"):
				#	currentAlign = "left"	
				if t != "hr>" and t != "br>" and t.find("##") and t.find("center>") and t.find("/center>") and t.find("iframe") and t.find("/iframe") and t.find("/a>"):
					textLine.text = t
					#match(currentAlign):
						#"left":
						#	textLine.ALIGN_LEFT
						#"center":
						#	textLine.ALIGN_CENTER
							
					$VBoxContainer.add_child(textLine)

	return output


func _on_Post_show_post(data):
	#$VBoxContainer/Label.text = 
	refresh = data
	track_formatter(data[1],data[2],data[4])
	pass # Replace with function body.

func _on_HTTPRequest_request_completed(_result, response_code, _headers, _body):
	if response_code == 200:
		emit_signal("show_post",refresh)
	pass # Replace with function body.
