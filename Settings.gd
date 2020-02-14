extends Control

var Thicket 
var OpenSeed
var first_launch = true

#User Options
var creatorMode = false
var privMode = false

#Network Options
var p2p = false
var ipfs = false

#System Options 
var cf = false
var replaceMedia = false
var includeApps = true
var includeEmulators = false

var mamePath = ""
var mednafenPath = ""
var mameRomPath = ""
var mednafenRomPath = ""
var customMusicFolder = ""
var customVideoFolder = ""

var imageFile = Image.new()
var profileTexture = ImageTexture.new()

var AccountInfo
var About
var System
var Network

signal show(what)
	
func _ready():
	OpenSeed = get_node("/root/OpenSeed")
	Thicket = get_node("/root/Thicket")
	AccountInfo = $Panel/AccountContainer/Account/HBoxContainer/AccountInfo
	About = $Panel/AccountContainer/Account/HBoxContainer/About/TextEdit
	System = $Panel/SystemContainer/System
	Network = $Panel/NetworkContainer/Network
	setup(Thicket.settings_load())
	
func _on_Settings_visibility_changed():
	if !self.visible and first_launch == false:
		cf = $Panel/ScrollContainer/VBoxContainer/customFolders.is_pressed()
		p2p = $Panel/ScrollContainer/VBoxContainer/p2p.is_pressed()
		ipfs = $Panel/ScrollContainer/VBoxContainer/ipfs.is_pressed()
		creatorMode = AccountInfo.get_node("creatorMode").is_pressed()
		var customMusicFolder = $Panel/ScrollContainer/VBoxContainer/Music/entry.text
		var customVideoFolder = $Panel/ScrollContainer/VBoxContainer/Video/entry.text
		save()


func setup(data) :
	if data :
		if data["customFolders"] == "False":
			cf = false 
		else: 
			cf = true
		if data["p2p"] == "False":
			p2p = false 
		else: 
			p2p = true
		if data["ipfs"] == "False":
			ipfs = false 
		else: 
			ipfs = true
		if data["creatorMode"] == "False":
			creatorMode = false 
		else: 
			creatorMode = true
		if data["Apps"] == "False":
			includeApps = false
		else:
			includeApps = true
		if data["Emulators"] == "False":
			includeEmulators = false
		else:
			includeEmulators = true

		$Panel/SystemContainer/System/customFolders.set_pressed(cf)
		$Panel/NetworkContainer/Network/p2p.set_pressed(p2p)
		$Panel/NetworkContainer/Network/ipfs.set_pressed(ipfs)
		AccountInfo.get_node("creatorMode").set_pressed(creatorMode)


func _on_Settings_show(what):
	match what:
		"account":
			$Panel/AccountContainer.show()
			$Panel/CreatorContainer.hide()
			$Panel/SystemContainer.hide()
			$Panel/NetworkContainer.hide()
		"network":
			$Panel/NetworkContainer.show()
			$Panel/CreatorContainer.hide()
			$Panel/SystemContainer.hide()
			$Panel/AccountContainer.hide()
		"system":
			$Panel/SystemContainer.show()
			$Panel/CreatorContainer.hide()
			$Panel/NetworkContainer.hide()
			$Panel/AccountContainer.hide()
		"creator":
			$Panel/CreatorContainer.show()
			$Panel/SystemContainer.hide()
			$Panel/NetworkContainer.hide()
			$Panel/AccountContainer.hide()
	pass # Replace with function body.


func _on_AccountContainer_visibility_changed():
	
	if $Panel/AccountContainer.visible:
		AccountInfo.get_node("HBoxContainer/Contact").block = imageFile
		AccountInfo.get_node("HBoxContainer/Contact").texblock = profileTexture
		AccountInfo.get_node("HBoxContainer/Contact").title = OpenSeed.username
		AccountInfo.get_node("HBoxContainer/Contact").pImage = OpenSeed.profile_image
		AccountInfo.get_node("HBoxContainer/VBoxContainer/Email").text = OpenSeed.profile_email
		AccountInfo.get_node("HBoxContainer/VBoxContainer/Name").text = OpenSeed.profile_name
		AccountInfo.get_node("HBoxContainer/VBoxContainer/Phone").text = OpenSeed.profile_phone
		About.text = OpenSeed.profile_about
		AccountInfo.get_node("HBoxContainer/Contact").emit_signal("refresh")
	pass # Replace with function body.


func _on_creatorMode_pressed():
	if AccountInfo.get_node("creatorMode").is_pressed():
		creatorMode = true
	else:
		creatorMode = false
	OpenSeed.profile_creator = creatorMode
	get_node("/root/MainWindow/Navi").nav_buttons("settings")
	save()


func _on_privMode_pressed():
	if AccountInfo.get_node("privMode").is_pressed():
		privMode = true
	else:
		privMode = false
	save()
	pass # Replace with function body.

func save():
	Thicket.settings_save(creatorMode,privMode,cf,replaceMedia,customMusicFolder,
	customVideoFolder,includeApps,includeEmulators,mamePath,mameRomPath,mednafenPath,mednafenRomPath,p2p,ipfs)


func _on_removeDups_pressed():
	if System.get_node("removeDups").is_pressed():
		replaceMedia = true
	else:
		replaceMedia = false
	save()
	pass # Replace with function body.


func _on_customFolders_pressed():
	if System.get_node("customFolders").is_pressed():
		cf = true
	else:
		cf = false
	save()
	pass # Replace with function body.


func _on_applications_pressed():
	if System.get_node("applications").is_pressed():
		includeApps = true
	else:
		includeApps = false
	save()
	pass # Replace with function body.


func _on_romFolders_pressed():
	if System.get_node("romFolders").is_pressed():
		includeEmulators = true
	else:
		includeEmulators = false
	save()
	pass # Replace with function body.


func _on_p2p_pressed():
	if Network.get_node("p2p").is_pressed():
		p2p = true
	else:
		p2p = false
	save()
	pass # Replace with function body.


func _on_ipfs_pressed():
	if Network.get_node("ipfs").is_pressed():
		ipfs = true
	else:
		ipfs = false
	save()
	pass # Replace with function body.


func _on_CreatorContainer_tab_changed(tab):
	var selected = $Panel/CreatorContainer.get_child(tab).name
	
	match(selected):
		"Music":
			pull_music(OpenSeed.token)
		"Videos":
			pull_videos(OpenSeed.token)
		"Applications":
			pull_apps(OpenSeed.token)
		"Games":
			pull_games(OpenSeed.token)
		"Profile":
			pull_profile(OpenSeed.token)
		"Digital Goods":
			pull_dg(OpenSeed.token)
			
	pass # Replace with function body.

func pull_music(account):
	$Panel/CreatorContainer/Music.loadUp("newenx")
	pass

func pull_videos(account):
	print("VIDEOS")
	pass

func pull_games(account):
	print("GAMES")
	pass

func pull_apps(account):
	print("APPS")
	pass

func pull_profile(account):
	print("PROFILE")
	pass
	
func pull_dg(account):
	print("Digital Goods")
	pass
