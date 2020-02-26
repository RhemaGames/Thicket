extends PanelContainer
var chatmessage = preload("res://elements/MessageBox.tscn")
var box 
var offset = 0
var key = ""
var SocialRoot
var OpenSeed
var Thicket
# Declare member variables here. Examples:
# var a = 2
# var b = "text"
# Called when the node enters the scene tree for the first time.
var last = 0

func _ready():
	SocialRoot = get_parent().get_parent().get_parent()
	OpenSeed = get_node("/root/OpenSeed")
	Thicket = get_node("/root/Thicket")
	OpenSeed.connect("chatdata",self,"update_chat")
	OpenSeed.connect("sent_chat",self,"chatbox_reset")
	
	box = $VBoxContainer/ScrollContainer/VBoxContainer
	$Timer.start()
	SocialRoot.connect("changeview",self,"_on_account_view")
	#if !SocialRoot.currentuser or SocialRoot.currentuser == OpenSeed.username:
	#	self.hide()
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass



func _on_Timer_timeout():
	OpenSeed.get_chat(OpenSeed.username,get_parent().get_parent().get_parent().currentuser,last)
		
	pass # Replace with function body.

func update_chat(data):
	if key == "":
			key = OpenSeed.get_keys_for(OpenSeed.username+","+get_parent().get_parent().get_parent().currentuser)
	elif key != "denied":
		if(len(data) > 10):
			var json = parse_json(data)
			if typeof(json) == TYPE_DICTIONARY:
				if json.has("index"):
					#$Timer.wait_time = 2
					box.get_parent().set_v_scroll(box.rect_size.y)
					var newmessage = chatmessage.instance()
					newmessage.date = json["date"]
					newmessage.speaker = json["type"]
					newmessage.message = OpenSeed.simp_decrypt(key,json["message"])
					#newmessage.message = "Testing "+last
					box.add_child(newmessage)
					box.get_parent().set_v_scroll(box.rect_size.y)
					last = json["index"]
					OpenSeed.get_chat(OpenSeed.username,get_parent().get_parent().get_parent().currentuser,last)
				elif json and json.has("type"):
					if json["type"] == "server":
						box.get_parent().set_v_scroll(box.rect_size.y)
						match json["message"]:
							"none":
								$Timer.wait_time = 10
			else:
				$Timer.wait_time = 4
			

func _on_message_text_entered(new_text):
	OpenSeed.send_chat(OpenSeed.simp_crypt(key,new_text),OpenSeed.username,get_parent().get_parent().get_parent().currentuser)
	pass # Replace with function body.

func _on_account_view(account):
	if account != OpenSeed.username:
		self.show()
	else:
		self.hide()
	pass

func chatbox_reset(data):
	$VBoxContainer/InputArea/message.text = ""
	pass
