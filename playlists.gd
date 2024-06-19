extends MenuButton

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var MusicRoot 
# Called when the node enters the scene tree for the first time.
func _ready():
	MusicRoot = get_parent().get_parent().get_parent()
# warning-ignore:return_value_discarded
	get_popup().connect("id_pressed", Callable(self, "menu_item_selected"))
	#load_playlists()


func menu_item_selected(item):
	var menu = get_popup()
	match item:
		1:
			MusicRoot.get_node("NewPlaylist").show()
		_:
			MusicRoot.load_playlist(menu.get_item_text(item))
			
func load_playlists():
	
	var children = get_popup().get_item_count()
	while children >= 3:
		get_popup().remove_item(children)
		children -= 1
		
	var dir = DirAccess.new()
	if dir.open("user://playlists") == OK:
		dir.list_dir_begin() # TODOConverter3To4 fill missing arguments https://github.com/godotengine/godot/pull/40547
		var playlist = dir.get_next()
		var _count = 0
		while playlist != "":
			get_popup().add_item(playlist.split(".")[0])
			_count += 1
			playlist = dir.get_next()

func _on_playlists_about_to_show():
	load_playlists()

