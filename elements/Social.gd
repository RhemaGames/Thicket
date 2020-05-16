extends Control
var con = preload("res://elements/Contact_info.tscn")
var textureList = []
var imageFile = Image.new()
var profileTexture = ImageTexture.new()
var textureFile = []
var contact_count = 0
var texture_count = 0
var connection = 0
var currentuser = OpenSeed.username
var chatbox

signal done()
signal changeview(account)

func _ready():
	chatbox = $Main/HBoxContainer/ChatLog
	chatbox.currentuser = currentuser
	chatbox.SocialRoot = self
# warning-ignore:return_value_discarded
	OpenSeed.connect("profiledata",self,"on_profile_return")
	OpenSeed.connect("userLoaded",self,"profileblock")
# warning-ignore:return_value_discarded
	OpenSeed.connect("connections",self,"get_connections")
	
	
func profileblock():
	var loggedIn = $Chat/VBoxContainer/User_info
	loggedIn.account = OpenSeed.username
	textureFile.append(ImageTexture.new())
	loggedIn.get_node("Contact").block = imageFile
	loggedIn.get_node("Contact").texblock = textureFile[texture_count]
	loggedIn.get_node("Contact").title = OpenSeed.username
	loggedIn.get_node("Contact").pImage = OpenSeed.profile_image
	loggedIn.get_node("UserName").text = OpenSeed.profile_name
	loggedIn.get_node("Activity").text = "Account: "+OpenSeed.username
	loggedIn.get_node("Contact").emit_signal("refresh")
	loggedIn.connect("view",self,"set_view")
	texture_count += 1
	currentuser = OpenSeed.username
	set_view(OpenSeed.username)
	emit_signal("done")
	
func _on_Social_visibility_changed():
	if visible and $ScrollContainer/Connections.get_child_count() == 0:
		list_connections()
		
func list_connections():
	$iterate_connections.start()
	
func get_connections(_data):
	$iterate_connections.start()
	
	
func setup_connection(dat,_count):
	var next = con.instance()
	var name = ""
	var image = ""
	var perp = dat["profile"]
	var username = dat["username"]
	next.account = username
	#var current_status = {"status":"offline"}
	if perp.keys().has("openseed"):
		var profile = perp["openseed"]
		var hiveProfile = perp["imports"]
		if profile.keys().has("name"):
			name = profile["name"]
			if hiveProfile.keys().has("profile"):
				if str(hiveProfile["profile"]) != "Not found":
					image = hiveProfile["profile"]["profile_image"]
					textureFile.append(ImageTexture.new())
					next.get_node("Contact").texblock = textureFile[texture_count]
					next.get_node("Contact").block = imageFile
					next.get_node("Contact").pImage = image
					texture_count +=1
			next.get_node("Contact").title = username
			next.get_node("UserName").text = name
			if dat.keys().has("linked"):
				if dat["linked"] == 1:
					next.get_node("Activity").text = "Please Wait"
					next.connect("view",self,"_Show_connect_opts")
				elif dat["linked"] == 2:
					next.connect("view",self,"_on_Social_view")
					next.get_node("Activity").text = "Please Wait"
					
			$Chat/VBoxContainer/UserLists/VBox/Online/list.add_child(next)
		contact_count +=1
	$iterate_connections.start()
	
func _on_iterate_connections_timeout():
	if Thicket.connections_list and Thicket.connections_list.size() > 1 and connection < Thicket.connections_list.size():
		$iterate_connections.stop()
		if connection >= 0:
			setup_connection(Thicket.connections_list[connection],contact_count)
		else:
			$iterate_connections.start()
		connection += 1
	else:
		$iterate_connections.stop()
	
func _on_Social_done():
	#set_view(OpenSeed.username)
	OpenSeed.openSeedRequest("history",[OpenSeed.username,"all","10"])
	#OpenSeed.openSeedRequest("getProfile",[OpenSeed.username])
	pass
	
func set_view(account):
	print("setting view for "+account)
	$Main/Recent/TextInfo/Name.text = ""
	$Main/Recent/TextInfo/TagLine.text = ""
	$Main/Recent/Contact.pImage = ""
	$Main/Recent/Contact.title = ""
	$Main/Recent/Contact.title = account
	$Main/Recent/Contact.block = imageFile
	$Main/Recent/Contact.texblock = profileTexture
	
	if account == OpenSeed.username:
		$Main/Recent/TextInfo/Name.text = OpenSeed.profile_name
		$Main/Recent/TextInfo/TagLine.text = OpenSeed.profile_about
		$Main/Recent/Contact.pImage = OpenSeed.profile_image
		$Main/HBoxContainer/ChatLog.hide()
		$Main/HBoxContainer/UserSettings.show()
	else:
		$Main/HBoxContainer/ChatLog.show()
		$Main/HBoxContainer/UserSettings.hide()
		OpenSeed.openSeedRequest("getProfile",[account])
		currentuser = account
		$Main/HBoxContainer/ChatLog.currentuser = account
		
		
		$Main/Recent/Contact.pImage = ""
		
	$Main/Recent/Contact.emit_signal("refresh")
	OpenSeed.openSeedRequest("history",[account,"all","10"])
	chatbox.emit_signal("change_user",account)
	
func _on_Social_view(account):
	$AnimationPlayer.play("Load")
	set_view(account)
	emit_signal('changeview',account)
	
func _Show_connect_opts(account):
	OpenSeed.emit_signal("interface","request",account)
	
func _on_status_update_timeout():
	OpenSeed.openSeedRequest("updateStatus",['{"chat":"Online"}'])

func on_profile_return(profile):
	if profile[0] == currentuser:
		if profile[1].has("openseed"):
			$Main/Recent/TextInfo/Name.text = profile[1]["openseed"]["name"]
			if profile[1]["imports"].has("profile"):
				if str(profile[1]["imports"]["profile"]) != "Not found":
					if profile[1]["imports"]["profile"].has("about"):
						$Main/Recent/TextInfo/TagLine.text = profile[1]["imports"]["profile"]["about"]
		else:
			$Main/Recent/TextInfo/Name.text = currentuser
