extends PanelContainer
var chatmessage = preload("res://elements/MessageBox.tscn")

var box 
var offset = 0
var key = ""
var room = ""
var SocialRoot
var OpenSeed
var Thicket
# Declare member variables here. Examples:
# var a = 2
# var b = "text"
# Called when the node enters the scene tree for the first time.
var last = 0
# warning-ignore:unused_signal
signal change_user(currentuser)

var history_retrieved = false

var chat_history = {}

func _ready():
	SocialRoot = get_parent().get_parent().get_parent()
	OpenSeed = get_node("/root/OpenSeed")
	Thicket = get_node("/root/Thicket")
	OpenSeed.connect("chatdata",self,"update_chat")
	OpenSeed.connect("sent_chat",self,"chatbox_reset")
	OpenSeed.connect("chat_history",self,"fast_chat_update")
	OpenSeed.connect("conversations",self,"_on_conversations_update")
	
	box = $VBoxContainer/ScrollContainer/VBoxContainer
	$Timer.start()
	SocialRoot.connect("changeview",self,"_on_account_view")
	#if !SocialRoot.currentuser or SocialRoot.currentuser == OpenSeed.username:
	#	self.hide()
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
func get_key():
	if room != "":
		var cuser = get_parent().get_parent().get_parent().currentuser
		key = OpenSeed.get_keys_for(OpenSeed.username+","+cuser,room)


func _on_Timer_timeout():
	var cuser = get_parent().get_parent().get_parent().currentuser
	if cuser and OpenSeed.username != cuser:
		room = OpenSeed.find_by_attendees([cuser,OpenSeed.username])
		if room != "" and history_retrieved == false :
			OpenSeed.get_chat_history(room,5,0)



func update_chat(data):
	#var cuser = get_parent().get_parent().get_parent().currentuser
	if key != "denied":
		if(len(str(data)) > 10):
			var json = data
			if json.has("index") and json["index"] != "-1":
				#$Timer.wait_time = 2
				box.get_parent().set_v_scroll(box.rect_size.y)
				var newmessage = chatmessage.instance()
				newmessage.date = json["date"]
				newmessage.speaker = json["speaker"]
				newmessage.message = OpenSeed.simp_decrypt(key,json["message"])
				box.add_child(newmessage)
				#var current_pos = box.get_parent().get_v_scroll()
				#box.get_parent().set_v_scroll(current_pos+newmessage.rect_size.y)
				last = json["index"]
				#OpenSeed.get_chat(room,last)
			elif json and json.has("speaker"):
				if json["speaker"] == "server":
					#box.get_parent().set_v_scroll(box.rect_size.y)
					match json["message"]:
						"none":
							$Timer.wait_time = 40
	else:
		$Timer.wait_time = 200

func _on_message_text_entered(new_text):
	var returned = ""
	#var cuser = get_parent().get_parent().get_parent().currentuser
	if room != "":
		if key:
			returned = OpenSeed.send_chat(OpenSeed.simp_crypt(key,new_text),room)
		else:
			returned = OpenSeed.send_chat(new_text,room)
	if returned != "":
		#box.get_parent().set_v_scroll(box.rect_size.y)
		$VBoxContainer/InputArea/message.text = ""

func _on_account_view(account):
	if account != OpenSeed.username:
		self.show()
	else:
		self.hide() 	

func chatbox_reset(data):
	#var cuser = get_parent().get_parent().get_parent().currentuser
	var text = $VBoxContainer/InputArea/message.text
	if data:
		OpenSeed.get_chat(room,last)
	else:
		_on_message_text_entered(text)
	pass

func fast_chat_update(data):
	var dat = data
	if typeof(dat) == TYPE_ARRAY:
		for line in dat:
			update_chat(line)
		history_retrieved = true
	pass


func _on_ChatLog_change_user(currentuser):
	
	history_retrieved = false
	chat_history = []
	while box.get_child_count() > 0:
		var thechild = box.get_child(box.get_child_count() -1)
		box.remove_child(thechild)
	room = OpenSeed.find_by_attendees([currentuser,OpenSeed.username])
	get_key()
	if room != "" and key != "":
		OpenSeed.get_chat_history(room,5,0)
	pass # Replace with function body.
	
func from_conversations(data):
	for conv in data:
		if conv["room"] == room:
			print(conv)


func _on_VBoxContainer_resized():
	var the_bottom = box.get_parent().get_child(2).max_value
	box.get_parent().set("vertical_scroll",the_bottom)
	box.get_parent().set_v_scroll(the_bottom)
	pass


func _on_ScrollContainer_scroll_ended():
	print("Scroll position: "+str(box.get_parent().get_v_scroll()))
	pass # Replace with function body.
	
func _on_conversations_update(_data):
	var cuser = get_parent().get_parent().get_parent().currentuser
	for chatroom in OpenSeed.conversations:
		if room == "":
			if chatroom["attendees"] == OpenSeed.username+","+cuser or chatroom["attendees"] == cuser+","+OpenSeed.username:
				room = chatroom["room"]
				if int(last) <= int(chatroom["index"]):
					OpenSeed.get_chat(room,last)

				break
		else:
			if chatroom["room"] == room:
				if int(last) <= int(chatroom["index"]):
					OpenSeed.get_chat(room,last)
				break
