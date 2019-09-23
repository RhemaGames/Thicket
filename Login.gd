extends Control

var openseed 
# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var username = ""
var passphrase = ""
var newtoken = ""
signal login(status)
# Called when the node enters the scene tree for the first time.
func _ready():
	#openseed.loadUserData()
	#if openseed.token:
		#emit_signal("login",1)
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Username_text_changed(new_text):
	username = new_text

func _on_Passphrase_text_changed(new_text):
	passphrase = new_text

func _on_New_pressed():
	get_parent().get_node("NewAccount/Username").text = username
	get_parent().get_node("NewAccount/Passphrase").text = passphrase
	get_parent().get_node("NewAccount").visible = true
	self.hide()

func _on_Okay_pressed():
	var response = openseed.verify_account(username,passphrase)
	match response.split("\n")[0]:
		"denied":
			$notification.text = response
		"-1":
			$notification.text = "No User Found"
		_:
			$notification.text = "granted" 
			emit_signal("login",1)
			if len(openseed.token) < 2:
				openseed.token = response.split("\n")[0]
			openseed.username = username
			openseed.saveUserData()
			
	pass # Replace with function body.


func _on_Login_visibility_changed():
	if visible:
		openseed = get_parent().get_parent().get_node("OpenSeed")
	pass # Replace with function body.
