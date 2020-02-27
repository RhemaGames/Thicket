extends Panel
var fallback_audio = preload("res://Img/folder-music-symbolic.svg")

var Thicket
var OpenSeed

var MusicRoot

var title = ""
var imgfile = File.new()
var block = ""
var texblock = ""
var highlight = false
var loadAnimDone = false

signal refresh()
signal search(artist)
# Called when the node enters the scene tree for the first time.

func _ready():
	Thicket = get_node("/root/Thicket")
	OpenSeed = get_node("/root/OpenSeed")
	if get_tree().get_root().get_child(2).name == "Loader":
		MusicRoot = get_tree().get_root().get_child(2).get_node("MainWindow").get_node("WindowContainer").get_node("Music")
	else:
		MusicRoot = get_tree().get_root().get_node("MainWindow").get_node("WindowContainer").get_node("Music")
	if get_index() == 0:
		$Timer.wait_time = 0.01
	else:
		$Timer.wait_time = 0.05 * get_index()
	$Timer.start()
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func set_box(profile,account):
	
	if profile and profile.find('"profile":"Not found"') == -1:
		Thicket.local_knowledge_add("/artists/"+account,'{"ProfileImage":"user://cache/Img/'+account+'ProfileImg"}')
		var pfile = parse_json(profile)
		if str(pfile["profile"].keys()).find("name") != -1:
			$title.text = pfile["profile"]["name"]
		else:
			$title.text = account
		Thicket.local_knowledge_add("/artists/"+account,'{"ProfileName":"'+$title.text+'"}')
		if !imgfile.file_exists("user://cache/Img/"+account+"ProfileImg"):
			if str(pfile["profile"].keys()).find("profile_image") != -1:
				get_pimage(account,pfile["profile"]["profile_image"])
		else:
			$TextureRect.set_texture(get_image("user://cache/Img/"+account+"ProfileImg"))
	#$TextureRect.set_texture(get_image("user://cache/"+account+"ProfileImg"))
	
	
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
	
func get_pimage(account,image):
	$HTTPRequest.set_download_file("user://cache/Img/"+account+"ProfileImg")
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
		$TextureRect.set_texture(get_image($HTTPRequest.get_download_file()))
		
	pass # Replace with function body.


# warning-ignore:unused_argument
func _on_MusicBoxLarge_gui_input(event):
	if Input.is_mouse_button_pressed(1):
		emit_signal("search",title)
		
	if event is InputEventMouseMotion and loadAnimDone == true:
		if highlight == false:
			$AnimationPlayer.play("highlight")
			highlight = true
			$highlight_timer.start()

	pass # Replace with function body.


func _on_Timer_timeout():
	set_box(OpenSeed.get_steem_account(title),title)
	$AnimationPlayer.play("active")
	$Timer.stop()
	pass # Replace with function body.


func _on_highlight_timer_timeout():
	if !$AnimationPlayer.is_playing():
		$AnimationPlayer.play_backwards("highlight")
		highlight = false
		$highlight_timer.stop()
	pass # Replace with function body.


func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "active":
		loadAnimDone = true
		
	pass # Replace with function body.


func _on_MusicBoxLarge_refresh():
	$Timer.start()
	pass # Replace with function body.
