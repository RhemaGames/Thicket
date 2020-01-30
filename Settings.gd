extends Control
var thicket = load("res://elements/Thicket.gd")
var Thicket = thicket.new()
var first_launch = true

var cf = false
var p2p = false
var ipfs = false
var creatorMode = false

var imageFile = Image.new()
var profileTexture = ImageTexture.new()

var AccountInfo
var About

signal show(what)
	
func _ready():
	AccountInfo = $Panel/AccountContainer/Account/HBoxContainer/AccountInfo
	About = $Panel/AccountContainer/Account/HBoxContainer/About/TextEdit
	setup(Thicket.settings_load())
	
func _on_Settings_visibility_changed():
	if !self.visible and first_launch == false:
		cf = $Panel/ScrollContainer/VBoxContainer/customFolders.is_pressed()
		p2p = $Panel/ScrollContainer/VBoxContainer/p2p.is_pressed()
		ipfs = $Panel/ScrollContainer/VBoxContainer/ipfs.is_pressed()
		creatorMode = AccountInfo.get_node("creatorMode").is_pressed()
		var customMusicFolder = $Panel/ScrollContainer/VBoxContainer/Music/entry.text
		var customVideoFolder = $Panel/ScrollContainer/VBoxContainer/Video/entry.text
		
		Thicket.settings_save(cf,p2p,ipfs,creatorMode,customMusicFolder,customVideoFolder)


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
		
		if data["devMode"] == "False":
			creatorMode = false 
		else: 
			creatorMode = true
		
		$Panel/ScrollContainer/VBoxContainer/customFolders.set_pressed(cf)
		$Panel/ScrollContainer/VBoxContainer/p2p.set_pressed(p2p)
		$Panel/ScrollContainer/VBoxContainer/ipfs.set_pressed(ipfs)
		AccountInfo.get_node("creatorMode").set_pressed(creatorMode)


func _on_Settings_show(what):
	match what:
		"account":
			$Panel/AccountContainer.show()
			$Panel/SystemContainer.hide()
			$Panel/NetworkContainer.hide()
		"network":
			$Panel/NetworkContainer.show()
			$Panel/SystemContainer.hide()
			$Panel/AccountContainer.hide()
		"system":
			$Panel/SystemContainer.show()
			$Panel/NetworkContainer.hide()
			$Panel/AccountContainer.hide()
	pass # Replace with function body.


func _on_AccountContainer_visibility_changed():
	
	if $Panel/AccountContainer.visible:
		AccountInfo.get_node("Contact").block = imageFile
		AccountInfo.get_node("Contact").texblock = profileTexture
		AccountInfo.get_node("Contact").title = OpenSeed.username
		AccountInfo.get_node("Contact").pImage = OpenSeed.profile_image
		AccountInfo.get_node("Email").text = OpenSeed.profile_email
		AccountInfo.get_node("Name").text = OpenSeed.profile_name
		About.text = OpenSeed.profile_about
		AccountInfo.get_node("Contact").emit_signal("refresh")
	pass # Replace with function body.
