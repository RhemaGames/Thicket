extends Control
var thicket = load("res://elements/Thicket.gd")
var Thicket = thicket.new()
# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var first_launch = true

var cf = false
var p2p = false
var ipfs = false
var devMode = false
	
# Called when the node enters the scene tree for the first time.
func _ready():
	setup(Thicket.settings_load())
	
func _on_Settings_visibility_changed():
	if !self.visible and first_launch == false:
		cf = $Panel/ScrollContainer/VBoxContainer/customFolders.is_pressed()
		p2p = $Panel/ScrollContainer/VBoxContainer/p2p.is_pressed()
		ipfs = $Panel/ScrollContainer/VBoxContainer/ipfs.is_pressed()
		devMode = $Panel/ScrollContainer/VBoxContainer/devMode.is_pressed()
		var customMusicFolder = $Panel/ScrollContainer/VBoxContainer/Music/entry.text
		var customVideoFolder = $Panel/ScrollContainer/VBoxContainer/Video/entry.text
		
		Thicket.settings_save(cf,p2p,ipfs,devMode,customMusicFolder,customVideoFolder)


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
			devMode = false 
		else: 
			devMode = true
		
		$Panel/ScrollContainer/VBoxContainer/customFolders.set_pressed(cf)
		$Panel/ScrollContainer/VBoxContainer/p2p.set_pressed(p2p)
		$Panel/ScrollContainer/VBoxContainer/ipfs.set_pressed(ipfs)
		$Panel/ScrollContainer/VBoxContainer/devMode.set_pressed(devMode)
