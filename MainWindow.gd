extends Control
var social = 0
const HEIGHT = 1335
const WIDTH =  720
# warning-ignore:unused_signal
signal checksteem()
# Called when the node enters the scene tree for the first time.
func _ready():
	$OpenSeed.loadUserData()
	$Thicket.create_folders()
	check_devMode()

func _on_DevCon_pressed():
	if !$WindowContainer/DevConWindow.visible:
		$WindowContainer/DevConWindow.show()
	else:
		$WindowContainer/DevConWindow.hide()
		
func _on_Social_pressed():
	if social == 0:
		$Social/AnimationPlayer.play("toggle")
		social = 1
	else:
		$Social/AnimationPlayer.play_backwards("toggle")
		social = 0

# warning-ignore:unused_argument
func _on_Login_login(status):
	$Wizards/Login.hide()
	#if !$OpenSeed.steem:
	#	$Wizards/SteemLink.show()
	#else:
	$WindowContainer/Music.show()

func _on_Settings_pressed():
	if !$WindowContainer/Settings.visible :
		$WindowContainer/Settings.show()
		$WindowContainer/Settings.first_launch = false
	else:
		$WindowContainer/Settings.hide()
		check_devMode()


func _on_Games_pressed():
	if !$WindowContainer/Games.visible :
		$WindowContainer/Games.show()
		$WindowContainer/Videos.hide()
		$WindowContainer/Music.hide()
	else:
		$WindowContainer/Games.hide()


func _on_Audio_pressed():
	if !$WindowContainer/Music.visible :
		$WindowContainer/Music.show()
		$WindowContainer/Games.hide()
		$WindowContainer/Videos.hide()
	else:
		$WindowContainer/Music.show()

func _on_Video_pressed():
	if !$WindowContainer/Videos.visible :
		$WindowContainer/Videos.show()
		$WindowContainer/Games.hide()
		$WindowContainer/Music.hide()
	else:
		$WindowContainer/Videos.hide()


func check_devMode():
	if $WindowContainer/Settings.devMode == false:
		$BottomBar/HBoxContainer/DevCon.hide()
	else:
		$BottomBar/HBoxContainer/DevCon.show()

func _on_MainWindow_checksteem():
	#if !$OpenSeed.steem:
	#	 $Wizards/SteemLink.show()
	pass


func _on_SteemLink_linked():
	#$Wizards/SteemLink.hide()
	pass

func _on_OpenSeed_userLoaded():
	if !$OpenSeed.token:
		$Wizards/Welcome.show()
	#elif !$OpenSeed.steem:
	#	$Wizards/SteemLink.show()
	else:
		$Timer.start()



func _on_Timer_timeout():
	$WindowContainer/Music.show()
	$Timer.stop()
	pass # Replace with function body.


func _on_TopBar_gui_input(event):
	#var drag = Input.is_mouse_button_pressed(1)
	#var current_pos = OS.get_window_position()
	#if drag:
	#	if event is InputEventMouseMotion:
		#	var move = event.get_relative()
		#	OS.set_window_position(Vector2(current_pos.x+move.x,current_pos.y+move.y))
		#	current_pos = OS.get_window_position()
	pass # Replace with function body.
