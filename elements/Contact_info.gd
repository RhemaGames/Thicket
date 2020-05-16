extends Control

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var request_stat = "Please Wait"
var account = ""
var room = ""
var seen = true
var currentindex = 0
var soundeffect = preload("res://sound/piano01.ogg")
signal view(account)
# Called when the node enters the scene tree for the first time.
func _ready():
	$Contact.emit_signal("refresh")
	$newMessage.visible = false
# warning-ignore:return_value_discarded
	OpenSeed.connect("conversations",self,"_on_conversations_update")
# warning-ignore:return_value_discarded
	OpenSeed.connect("user_status",self,"_on_status_update")
# warning-ignore:return_value_discarded
	OpenSeed.connect("request_status",self,"_on_request_status_update")
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _on_Contact_info_gui_input(event):
	if event is InputEventMouseButton and event.get_button_index() == 1 and event.is_pressed():
		
		if request_stat != "pending":
			emit_signal("view",account)
		else:
			OpenSeed.interface("request",true,account)
		$newMessage.visible = false


func _on_conversations_update(_data):
	for chatroom in OpenSeed.conversations:
		if room == "":
			if chatroom["attendees"] == OpenSeed.username+","+account or chatroom["attendees"] == account+","+OpenSeed.username:
				room = chatroom["room"]
				if currentindex != chatroom["index"]:
					currentindex = chatroom["index"]
					$newMessage.visible = true
					$AudioStreamPlayer.set_stream(soundeffect)
					$AudioStreamPlayer.pitch_scale = 0.5 + (0.1 * get_index())
					$AudioStreamPlayer.play()
				break
		else:
			if chatroom["room"] == room:
				if currentindex != chatroom["index"]:
					currentindex = chatroom["index"]
					$newMessage.visible = true
					$AudioStreamPlayer.set_stream(soundeffect)
					$AudioStreamPlayer.pitch_scale = 0.5 + (0.1 * get_index())
					$AudioStreamPlayer.play()
				break

func _on_status_update(status):
	if status[1] == account:
		if request_stat == "accepted":
			$Activity.text = status[0]
		elif request_stat == "denied":
			queue_free()
		elif request_stat == "pending":
			$Activity.text = "pending"

func _on_request_status_update(request):
	if request[1] == account:
		request_stat = request[0]
	pass

func _on_Timer_timeout():
	$Timer.wait_time = 90
	if account != OpenSeed.username:
		OpenSeed.get_request_status(account)
		OpenSeed.get_openseed_account_status(account)
		
	

