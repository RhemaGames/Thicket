extends GridContainer
var playlist = preload("res://elements/playList.tscn")
var genres = preload("res://elements/GenreBox.tscn")
# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	populate_recent()
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func populate_recent():
	var PlayList = playlist.instance()
	var Genres = genres.instance()
	#get_parent().get_parent().get_parent().get_node("Thicket").playlist_load("recent")
	PlayList.title = "recent"
	add_child(PlayList)
	add_child(Genres)