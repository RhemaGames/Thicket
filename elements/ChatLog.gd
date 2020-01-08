extends PanelContainer
var chatmessage = preload("res://elements/MessageBox.tscn")
var box 
var offset = 0
var key = ""
# Declare member variables here. Examples:
# var a = 2
# var b = "text"
# Called when the node enters the scene tree for the first time.
var last = 0

func _ready():
	OpenSeed.connect("chatdata",self,"update_chat")
	OpenSeed.connect("sent_chat",self,"chatbox_reset")
	box = $VBoxContainer/ScrollContainer/VBoxContainer
	$Timer.start()
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func get_chat(username,account):
	if account:
		OpenSeed.thread.start(OpenSeed,"get_from_socket_threaded",['{"act":"get_chat","appID":"'+str(OpenSeed.appId)+'","devID":"'+str(OpenSeed.devId)+'","uid":"'+username+'","account":"'+account+'","room":"'+username+','+account+'","last":"'+str(last)+'"}',"chat"])


func _on_Timer_timeout():
	get_chat(OpenSeed.username,get_parent().get_parent().get_parent().currentuser)
		
	pass # Replace with function body.

func update_chat(data):
	var json = parse_json(data) 
	if key == "":
		key = OpenSeed.get_keys_for(OpenSeed.username+","+get_parent().get_parent().get_parent().currentuser)
	elif key != "denied":
		if json and json.has("index"):
			$Timer.wait_time = 1
			box.get_parent().set_v_scroll(box.rect_size.y)
			var newmessage = chatmessage.instance()
			newmessage.date = json["date"]
			newmessage.speaker = json["type"]
			newmessage.message = OpenSeed.simp_decrypt(key,json["message"])
			box.add_child(newmessage)
			box.get_parent().set_v_scroll(box.rect_size.y)
			last = json["index"]
		else:
			$Timer.wait_time = 2
			

func send_chat(message,username,account):
	if account:
		OpenSeed.thread.start(OpenSeed,"get_from_socket_threaded",['{"act":"send_chat","appID":"'+str(OpenSeed.appId)+'","devID":"'+str(OpenSeed.devId)+'","uid":"'+OpenSeed.token+'","username":"'+username+'","account":"'+account+'","data":"'+message+'"}',"send_chat"])
	
func _on_message_text_entered(new_text):
	#print(new_text)
	#print(key)
	send_chat(OpenSeed.simp_crypt(key,new_text),OpenSeed.username,get_parent().get_parent().get_parent().currentuser)
	pass # Replace with function body.

func chatbox_reset(data):
	$VBoxContainer/InputArea/message.text = ""
	pass
