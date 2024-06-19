extends GridContainer
var playlist = preload("res://elements/playList.tscn")
var genres = preload("res://elements/GenreBox.tscn")
# Declare member variables here. Examples:
# var a = 2
# var b = "text"
# warning-ignore:unused_signal
signal loadup()

# Called when the node enters the scene tree for the first time.
func _ready():
	
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func populate_recent():
	var PlayList = playlist.instantiate()
	var Genres = genres.instantiate()
	#get_parent().get_parent().get_parent().get_node("Thicket").playlist_load("recent")
	PlayList.title = "recent"
	add_child(PlayList)
	add_child(Genres)

func _on_playlistGrid_loadup():
	var children = get_child_count() -1
	while children >= 0:
		remove_child(get_child(children))
		children -= 1
		
	populate_recent()
	pass # Replace with function body.
