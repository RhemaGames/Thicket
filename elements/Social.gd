extends Control
var con = preload("res://elements/Contact_info.tscn")
# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var textureList = []
var imageFile = Image.new()
var profileTexture = ImageTexture.new()
var textureFile = []
var contact_count = 0
var texture_count = 0
var connection = 0
var currentuser = OpenSeed.username

signal done()

signal view(account)
# Called when the node enters the scene tree for the first time.
func _ready():
	if $Chat/VBoxContainer/Online.get_child_count() == 0:
		list_connections()
	set_view(OpenSeed.username)	
	$AnimationPlayer.play("Load")
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass



func _on_Social_visibility_changed():
	if visible and $ScrollContainer/Connections.get_child_count() == 0:
		list_connections()
	pass # Replace with function body.

func list_connections():
	#for connection in :
	$iterate_connections.start()
	
		#next.emit_signal("get_person",)

func setup_connection(person,count):
	var next = con.instance()
	var name = ""
	var image = ""
	if len(person.split(", ")) > 1:
		var perp = person.split(", ")[1]
		var username = person.split(", ")[0].split('"')[1]
		next.account = username
		var current_status = {"status":"offline"}
		var get_status = OpenSeed.get_openseed_account_status(username)
		while !get_status:
			print(get_status)
		current_status = get_status
		if parse_json(perp).keys().has("data1"):
			var profile = parse_json(perp)["data1"]
			var steemProfile = parse_json(perp)["data5"]
			if profile.keys().has("name"):
				next.connect("view",self,"_on_Social_view")
				name = profile["name"]
				if steemProfile.keys().has("profile"):
					if str(steemProfile["profile"]) != "Not found":
						image = steemProfile["profile"]["profile_image"]
						textureFile.append(ImageTexture.new())
						next.get_node("Contact").block = imageFile
						next.get_node("Contact").texblock = textureFile[texture_count]
						next.get_node("Contact").title = username
						next.get_node("Contact").pImage = image
						texture_count +=1
				next.get_node("UserName").text = name
				if !current_status.has("status"):
					if current_status["data"]["chat"] != "Offline":
						next.get_node("Activity").text = "Online"
					else:
						next.get_node("Activity").text = "Offline"
					$Chat/VBoxContainer/Online/list.add_child(next)

			contact_count +=1
	$iterate_connections.start()

func _on_iterate_connections_timeout():
	if Thicket.connections_list and Thicket.connections_list.size() > 1 and connection < Thicket.connections_list.size():
		$iterate_connections.stop()
		if connection > 0:
			setup_connection(Thicket.connections_list[connection],contact_count)
		else:
			$iterate_connections.start()
		connection += 1
	else:
		$iterate_connections.stop()
		emit_signal("done")
	pass # Replace with function body.

func _on_Social_done():
	OpenSeed.loadUserProfile(OpenSeed.username)
	set_view(OpenSeed.username)
	pass # Replace with function body.
	
func set_view(account):
	$TopBanner/TextInfo/Name.text = ""
	$TopBanner/TextInfo/TagLine.text = ""
	$TopBanner/Contact.pImage = ""
	$TopBanner/Contact.title = ""
	$TopBanner/Contact.title = account
	$TopBanner/Contact.block = imageFile
	$TopBanner/Contact.texblock = profileTexture
	
	if account == OpenSeed.username:
		$TopBanner/TextInfo/Name.text = OpenSeed.profile_name
		$TopBanner/TextInfo/TagLine.text = OpenSeed.profile_about
		$TopBanner/Contact.pImage = OpenSeed.profile_image
	else:
		var profile = OpenSeed.get_openseed_account(account)
		currentuser = account
		$TopBanner/TextInfo/Name.text = profile["data1"]["name"]
		if profile["data5"].has("profile"):
			if str(profile["data5"]["profile"]) != "Not found":
				if profile["data5"]["profile"].has("about"):
					$TopBanner/TextInfo/TagLine.text = profile["data5"]["profile"]["about"]
					
				
		
		$TopBanner/Contact.pImage = ""
		
	$TopBanner/Contact.emit_signal("refresh")	


func _on_Social_view(account):
	$AnimationPlayer.play("Load")
	set_view(account)
	pass # Replace with function body.


func _on_status_update_timeout():
	OpenSeed.set_openseed_account_status(OpenSeed.token,'{"location":"0:1","chat":"Online"}')
	pass # Replace with function body.
