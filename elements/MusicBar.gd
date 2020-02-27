extends Panel

var Thicket

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var stopImage = preload("res://Img/media-playback-stop-symbolic.svg")
var startImage = preload("res://Img/media-playback-start-symbolic.svg")
var noimage = preload("res://Img/folder-music-symbolic.svg")

signal tracktitle(title)
signal trackartist(artist)
signal songlength(length)
signal playposition(pos)
signal playing(playing)
signal trackart(art)
signal timeleft(time)

signal wait(status)

signal play_pressed(playing)

signal playlist_loaded(ready)

signal next_track()
signal previous_track()

var color = Color(1,1,1)

var theartist = ""
var is_playing = false
var is_ready = false

# Called when the node enters the scene tree for the first time.
func _ready():
	Thicket = get_node("/root/Thicket")
	emit_signal("trackartist","No Artist")
	emit_signal("tracktitle","No Title")
	emit_signal("songlength",0.0)
	emit_signal("playposition",0.0)
	emit_signal("playing",is_playing)
	emit_signal("trackart",noimage)
	#color = Thicket.selected_color
	
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_MusicBar_playing(playing):
	if playing == true:
		#self.self_modulate = Thicket.music_color
		#$PlayerControls.self_modulate = Thicket.music_color
		$songProgress.show()
		$PlayerStatus.show()
		$PlayerControls/HBoxContainer/play.set("texture_normal",stopImage)
		$PlayerControls/HBoxContainer/play.set("texture_hover",stopImage)
		$PlayerControls/HBoxContainer/play.set("texture_focus",stopImage)
		is_playing = true
	else: 
		#self.self_modulate = color
		#$PlayerControls.self_modulate = color
		$songProgress.hide()
		$PlayerStatus.hide()
		$PlayerControls/HBoxContainer/play.set("texture_normal",startImage)
		$PlayerControls/HBoxContainer/play.set("texture_hover",startImage)
		$PlayerControls/HBoxContainer/play.set("texture_focus",startImage)
		is_playing = false
		



func _on_MusicBar_playposition(pos):
	$songProgress.value = pos	
	
	pass # Replace with function body.


func _on_MusicBar_songlength(length):
	$songProgress.max_value = length
	pass # Replace with function body.


func _on_MusicBar_trackartist(artist):
	$PlayerStatus/playing/artist.text = artist
	theartist = artist
	pass # Replace with function body.


func _on_MusicBar_tracktitle(title):
	$PlayerStatus/playing/title.text = title+" : "+theartist
	pass # Replace with function body.


func _on_MusicBar_trackart(art):
	$PlayerStatus/playing.set_texture(art)
	pass # Replace with function body.


func _on_MusicBar_timeleft(time):
	$songProgress/left.text = time
	pass # Replace with function body.


func _on_play_pressed():
	if is_playing == false:
		emit_signal("play_pressed",true)
	else:
		emit_signal("play_pressed",false)
	pass # Replace with function body.


func _on_MusicBar_playlist_loaded(ready):
	if ready == true:
		if is_ready == false:
			is_ready = true
			#$AnimationPlayer.play("ready")
	else:
		is_ready = false
		#$AnimationPlayer.play_backward("ready")
		
	pass # Replace with function body.


func _on_nexttrack_pressed():
	emit_signal("next_track")
	pass # Replace with function body.


func _on_lasttrack_pressed():
	emit_signal("previous_track")
	pass # Replace with function body.


func _on_MusicBar_wait(status):
	if status == "show":
		$wait.show()
	else:
		$wait.hide()
	
	pass # Replace with function body.
