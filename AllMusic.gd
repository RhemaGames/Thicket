extends Control

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
# warning-ignore:return_value_discarded
	get_parent().connect("resized",self,"on_resize")
# warning-ignore:return_value_discarded
	get_node("/root/MainWindow").connect("loading_complete",self,"on_loading_done")

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func on_loading_done():
	OpenSeed.openSeedRequest("newtracks",[])
	OpenSeed.openSeedRequest("newartists",[])


func _on_AllMusic_visibility_changed():
	if visible:
		$resize.start()
		$Main/MainView/NewArtists.emit_signal("getNew")
		$Main.set_v_scroll(0)
		$Main/MainView/playlistGrid.emit_signal("loadup")



func _on_newMusic_pressed():
	
	var list = $Main/MainView/NewTracks._on_NewTracks_playlist()
	get_parent().playlist = get_parent().get_node("OptionView").create_list(list)
	get_parent().get_node("OptionView").show()
	self.hide()



func _on_NewArtistTimer_timeout():
	#if visible:
	#$Main/MainView/NewArtists.emit_signal("getNew")
	pass # Replace with function body.


func _on_NewTrackTimer_timeout():
	#if visible:
	#$Main/MainView/NewTracks.emit_signal("getNew")
	pass # Replace with function body.


func _on_Timer_timeout():
	#$Main/MainView/NewTracks.emit_signal("getNew")
	$Timer.stop()
	pass # Replace with function body.

func on_resize():
	if get_size().x != 0:
		$resize.start()

func _on_resize_timeout():
	$Main.rect_size = Vector2(get_size().x-12,get_size().y)
	$Main.queue_sort()
	$resize.stop()



func _on_artists_pressed():
	get_parent().get_node("title").text = "All Artists"
	get_parent().get_node("AllArtists").show()
	self.hide()
	pass # Replace with function body.
