extends Panel
var fallback_audio = preload("res://Img/folder-music-symbolic.svg")

var Thicket
var OpenSeed

var MusicRoot

var title = ""
var imgfile = File.new()
var block = ""
var texblock = ""
var img = ""
var the_img
var highlight = false
var loadAnimDone = false
var pfile = false

# warning-ignore:unused_signal
signal refresh()
signal search(artist)
# Called when the node enters the scene tree for the first time.

func _ready():
	Thicket = get_node("/root/Thicket")
	OpenSeed = get_node("/root/OpenSeed")
	#set_box(title,img)
	OpenSeed.openSeedRequest("get_image",[img,"medium"])
	OpenSeed.connect("imagestored",self,"refresh")
	OpenSeed.connect("profiledata",self,"on_profile_return")
	
	$title.text = title
	if get_tree().get_root().get_child(2).name == "Loader":
		MusicRoot = get_tree().get_root().get_child(2).get_node("MainWindow").get_node("WindowContainer").get_node("Music")
	else:
		MusicRoot = get_tree().get_root().get_node("MainWindow").get_node("WindowContainer").get_node("Music")
	if get_index() == 0:
		$Timer.wait_time = 0.01
	else:
		$Timer.wait_time = 0.05 * get_index()
	$Timer.start()


func set_box(title,imagehash):
	if imagehash != "No_Image_found" and imagehash != "":
		var fromStore = OpenSeed.get_from_image_store(imagehash)
		if !fromStore:
			the_img = OpenSeed.set_image(imagehash)
		else:
			the_img = fromStore
		$TextureRect.set_texture(the_img)
	$title.text = title

# warning-ignore:unused_argument
func _on_MusicBoxLarge_gui_input(event):
	if Input.is_mouse_button_pressed(1):
		emit_signal("search",title)
		
	if event is InputEventMouseMotion and loadAnimDone == true:
		if highlight == false:
			$AnimationPlayer.play("highlight")
			highlight = true
			$highlight_timer.start()


func _on_Timer_timeout():
	$Timer.stop()
	OpenSeed.openSeedRequest("get_hive_account",[title])
	$AnimationPlayer.play("active")

func on_profile_return(data):
	if pfile == false:
		if data[0] == title and data[1].has("profile"):
			if typeof(data[1]["profile"]) == TYPE_DICTIONARY:
				if data[1]["profile"].has("profile_image"):
					img = data[1]["profile"]["profile_image"]
					OpenSeed.openSeedRequest("get_image",[img,"medium"])
				if data[1]["profile"].has("name"):
					$title.text = data[1]["profile"]["name"]
					
			pfile = true	
	pass
		

func _on_highlight_timer_timeout():
	if !$AnimationPlayer.is_playing():
		$AnimationPlayer.play_backwards("highlight")
		highlight = false
		$highlight_timer.stop()



func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "active":
		loadAnimDone = true


func _on_MusicBoxLarge_refresh():
	pass
#	$Timer.start()

	
func refresh(data):
	if data[1] != "No_Image_found" and data[0] == img:
		var texbox = TextureRect.new()
		var fromStore = OpenSeed.get_from_image_store(data[1])
		if !fromStore:
			the_img = fallback_audio
		else:
			the_img = fromStore
		$TextureRect.set_texture(the_img)
