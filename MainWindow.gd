extends Control
var social = 0
const HEIGHT = 1335
const WIDTH =  720
# warning-ignore:unused_signal
var OpenSeed 
var Thicket 
signal checksteem()
signal loading_complete()
signal loading_start(what)
signal where(place)

# Called when the node enters the scene tree for the first time.
var active = ""


var sun = 0.0

func _ready():
	#$BG.self_modulate = Color(sun,sun,sun,1.0)
	OpenSeed = get_node("/root/OpenSeed")
	Thicket = get_node("/root/Thicket")
	Thicket.create_folders()

	
	
	
	$Navi/MusicBar.color = Color(0.2,0.2,0.2)
	#$Spatial/AnimationPlayer.play("slowwalk")

	if !OpenSeed.loadUserData():
		OpenSeed.get_node("CanvasLayer/Login").show()
	else:
		check_devMode()
		emit_signal("loading_start",self)

func _input(_event):
	if Input.is_key_pressed(KEY_F10):
		if OS.window_fullscreen == false:
			OS.window_fullscreen = true
		else:
			OS.window_fullscreen = false



func _on_DevCon_pressed():
	OpenSeed.check_ipfs()
	if !$WindowContainer/DevConWindow.visible:
		$WindowContainer/DevConWindow.show()
		
	else:
		$WindowContainer/DevConWindow.hide()
		
func _on_Social_pressed():
	if social == 0:
		$Social.show()
		social = 1
	else:
		$Social.hide()
		social = 0

# warning-ignore:unused_argument
func _on_Login_login(status):
	OpenSeed.get_node("CanvasLayer/Login").hide()
	#if !$OpenSeed.steem:
	#	$Wizards/SteemLink.show()
	#else:
	#$WindowContainer/Music.show()

func _on_Settings_pressed():
	if $Navi.active_area != "settings" :
		$WindowContainer/AnimationPlayer.play("Music",0.2,-5,true)
		$WindowContainer/AnimationPlayer.play("Games",0.2,-5,true)
		$WindowContainer/AnimationPlayer.play("Social",0.2,-5,true)
		$WindowContainer/AnimationPlayer.play("Apps",0.2,-5,true)
		$WindowContainer/AnimationPlayer.play("Settings",0.4,5)
		$WindowContainer/Settings.first_launch = false
		
		$Navi.nav_buttons("settings")	
		check_devMode()


func _on_Games_pressed():
	if !$WindowContainer/Games.visible :
		$WindowContainer/Games.show()
		$WindowContainer/Videos.hide()
		$WindowContainer/Music.hide()
		$TopBar/HBoxContainer2/Navgation.text = "Games"
	#else:
	#	$WindowContainer/Games.hide()


func _on_Audio_pressed():
	if !$WindowContainer/Music.visible :
		$WindowContainer/Music.show()
		$WindowContainer/Games.hide()
		$WindowContainer/Videos.hide()
		$TopBar/HBoxContainer2/Navgation.text = "Music"
	#else:
	#	$WindowContainer/Music.show()

func _on_Video_pressed():
	if !$WindowContainer/Videos.visible :
		$WindowContainer/Videos.show()
		$WindowContainer/Games.hide()
		$WindowContainer/Music.hide()
		$TopBar/HBoxContainer2/Navgation.text = "Video"
	#else:
	#	$WindowContainer/Videos.hide()


func check_devMode():
	if $WindowContainer/Settings.creatorMode == false:
		#$BottomBar/HBoxContainer/DevCon.hide()
		print("Not a dev!")
	else:
		print("Is a dev!")
		#$BottomBar/HBoxContainer/DevCon.show()
		

func _on_MainWindow_checksteem():
	#if !$OpenSeed.steem:
	#	 $Wizards/SteemLink.show()
	pass


func _on_SteemLink_linked():
	#$Wizards/SteemLink.hide()
	pass

func _on_OpenSeed_userLoaded():
	if !OpenSeed.token:
		$Wizards/Welcome.show()
	#elif !$OpenSeed.steem:
	#	$Wizards/SteemLink.show()
	#else:
	#	$Timer.start()



func _on_Timer_timeout():
	$WindowContainer/Music.show()
	$Timer.stop()
	pass # Replace with function body.


func _on_TopBar_gui_input(_event):
	#var drag = Input.is_mouse_button_pressed(1)
	#var current_pos = OS.get_window_position()
	#if drag:
	#	if event is InputEventMouseMotion:
		#	var move = event.get_relative()
		#	OS.set_window_position(Vector2(current_pos.x+move.x,current_pos.y+move.y))
		#	current_pos = OS.get_window_position()
	pass # Replace with function body.


func _on_Search_pressed():
	if $WindowContainer/AdvancedSearch.visible:
		$WindowContainer/AdvancedSearch.hide()
	else:
		$WindowContainer/AdvancedSearch.show()
		
	pass # Replace with function body.


func _on_MainWindow_loading_complete():
	#$Loading.hide()
	
	pass # Replace with function body.


func _on_MainWindow_loading_start(what):
	print("Loading")
	$Loading.what = what
	$Loading.show()
	$Loading.emit_signal("bootup")
	
	pass # Replace with function body.


func _on_Loading_alldone():
	$WindowContainer/Social.list_connections()
	$Loading/Label.text = "Gathering Friends"
	emit_signal("loading_complete")
	pass # Replace with function body.


func _on_Social_done():
	$Loading.hide()
	pass # Replace with function body.

func _process(_delta): 
	var theTime = OS.get_time()
	var theHour = "0"
	var theMinutes = "0"
	var theSeconds = "0"
	
	if theTime["hour"] < 10:
		theHour = theHour+str(theTime["hour"])
	else:
		theHour = str(theTime["hour"])
		
	if theTime["minute"] < 10:
		theMinutes = theMinutes+str(theTime["minute"])
	else:
		theMinutes = str(theTime["minute"])
		
	if theTime["second"] < 10:
		theSeconds = theSeconds+str(theTime["second"])
	else:
		theSeconds = str(theTime["second"])
		
	$TopBar/Time.text = theHour+":"+theMinutes+":"+theSeconds
	
	pass

func _on_AnimationPlayer_animation_finished(anim_name):
	$Navi.emit_signal("activeRelease","all")
	pass # Replace with function body.
	
func _on_Navi_activeRelease(_except):
	pass # Replace with function body.


func _on_Home_pressed():
	if !$WindowContainer/AnimationPlayer.is_playing():
			$WindowContainer/AnimationPlayer.play("Music",0.2,-5,true)
			$WindowContainer/AnimationPlayer.play("Games",0.2,-5,true)
			$WindowContainer/AnimationPlayer.play("Social",0.2,-5,true)
			$WindowContainer/AnimationPlayer.play("Settings",0.2,-5,true)
			$WindowContainer/AnimationPlayer.play("Apps",0.2,-5,true)	
			$Navi.nav_buttons("main")
			$TopBar/HBoxContainer2/Nav.text = " "
	pass # Replace with function body.


func _on_Settings_gui_input(_event):
	if Input.is_mouse_button_pressed(1):
			if !$WindowContainer/AnimationPlayer.is_playing():
				$WindowContainer/AnimationPlayer.play("Settings",0.2,5,true)
				#$WindowContainer/AnimationPlayer.play("Music",0.2,-5,true)
				#$WindowContainer/AnimationPlayer.play("Games",0.2,-5,true)
				$Navi.nav_buttons("main")	
			#if !$WindowContainer/Settings.visible :
			#$WindowContainer/Settings.show()
			$WindowContainer/Settings.first_launch = false
		#else:
			##$WindowContainer/Settings.hide()
			#check_devMode()
	pass # Replace with function body.


func _on_Account_pressed():
	pass # Replace with function body.


func _on_Power_pressed():
	get_tree().quit()
	pass # Replace with function body.
