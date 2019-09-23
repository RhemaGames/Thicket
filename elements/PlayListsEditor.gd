extends Control

var plist = preload("res://elements/plist.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_new_list_pressed():
	$HSplitContainer/Tracks/newListName.show()
	pass # Replace with function body.


func _on_cancel_pressed():
	$HSplitContainer/Tracks/newListName.hide()
	pass # Replace with function body.


func _on_create_pressed():
	if $Thicket.create_playlist($HSplitContainer/Tracks/newListName.text):
		print("Created")
		hide()
		load_lists()
	else:
		print("Exists")
	
func load_lists():
	var plistlist = $HSplitContainer/Lists/ScrollContainer/PlayListList
	var listsnum = plistlist.get_child_count()
	while listsnum > 0:
		var child = plistlist.get_child(listsnum)
		plistlist.remove_child(child)
		listsnum -= 1
	
	var dir = Directory.new()
	if dir.open("user://playlists/") == OK:
		dir.list_dir_begin(true,true)
		var playlists = dir.get_next()
		while playlists != "":
			var g = plist.instance()
			print(playlists.split(".")[0])
			g.emit_signal("title",playlists.split(".")[0])
			plistlist.add_child(g)
			#g.connect("pressed",self,"_on_g_pressed",[playlists.split(".")[0]])
			playlists = dir.get_next()


func _on_PlayListsEditor_visibility_changed():
	if visible:
		load_lists()
	
