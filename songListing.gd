extends Control

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var fileName = " "
var title = "n/a"
var artist = "n/a"
var duration = "n/a"
var image = ""
var post = ""
var tracknum = 0
var clickable = true
var fulltrack = ""
var MusicRoot

signal play(fileName,artist,title,image)
signal play_now(num)
signal postview(post,artist,image)
signal clear_highlight(track)
signal search(artist)

# Called when the node enters the scene tree for the first time.
func _ready():
	if get_tree().get_root().get_child(2).name == "Loader":
		MusicRoot = get_tree().get_root().get_child(2).get_node("MainWindow").get_node("WindowContainer").get_node("Music")
	else:
		MusicRoot = get_tree().get_root().get_node("MainWindow").get_node("WindowContainer").get_node("Music")
# warning-ignore:return_value_discarded
	get_parent().get_parent().connect("resized",self,"_on_Music_resized")
##	get_image("http://142.93.27.131","8080",image)
	$container/artist.text = artist
	$container/duration.text = duration
	$container/fileName.text = fileName
	$container/title.text = title
	$highlight.self_modulate = Thicket.music_color
	$Timer.start()
	if tracknum % 2 == 0:
		$bg.set_self_modulate(Color(0.1,0.1,0.1,0.5))
	if clickable == false:
		$container/artist.disabled = true

func _on_songListing_gui_input(event):
	if clickable == true:
		if event is InputEventMouseButton and event.pressed and Input.is_mouse_button_pressed(1): 
			$highlight.show()
			#emit_signal("play",fileName,artist,title,image)
			emit_signal("play",tracknum)
			emit_signal("postview",post,artist,image)
			emit_signal("clear_highlight",fileName)
	
		if event is InputEventMouseButton and event.is_doubleclick():
			emit_signal("play_now",tracknum)
			#get_parent().get_parent().get_parent().get_parent()._on_play_pressed()

func _on_Music_resized():
	$Timer.start()


func _on_Timer_timeout():
	var win_size = get_parent().get_parent().get_size()
	set_size(Vector2(win_size.x,48.0))
	$Timer.stop()

func _on_Music_visibility_changed():
	$Timer.start()
	
func _clear_highlight(track):
	if fileName != track:
		$highlight.hide()
	
#func get_image(url,port,thefile):
#		var file = File.new()
#		if thefile and !file.file_exists("user://cache/"+thefile):
#			$HTTPRequest.set_download_file("user://cache/"+thefile)
#			var headers = [
#				"User-Agent: Pirulo/1.0 (Godot)",
#				"Accept: */*"
#			]
#			$HTTPRequest.request(str(url)+":"+str(port)+"/ipfs/"+str(thefile),headers,false,HTTPClient.METHOD_GET)

func _on_artist_pressed():
	emit_signal("search",artist)
	pass # Replace with function body.


func _on_playlist_pressed():
	if clickable == true:
		MusicRoot.get_node("PlaylistAdd").emit_signal("add_track",fulltrack)
	pass # Replace with function body.
