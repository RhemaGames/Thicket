extends PanelContainer
var history_item = preload("res://elements/historyItem.tscn")
var OpenSeed
var Thicket
var SocialRoot

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	SocialRoot = get_parent().get_parent().get_parent()
	OpenSeed = get_node("/root/OpenSeed")
	Thicket = get_node("/root/Thicket")
	OpenSeed.connect("historydata", Callable(self, "show_history"))
	SocialRoot.get_node("history_update").start()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_history_update_timeout():
	#var history 
	if SocialRoot.currentuser:
		OpenSeed.openSeedRequest("history",[SocialRoot.currentuser,"all","10"])
	else:
		OpenSeed.openSeedRequest("history",[OpenSeed.username,"all","10"])
	pass 
	
func show_history(data):
	var history = $VBoxContainer/ScrollContainer/VBoxContainer
	var num = 0
	while num < history.get_child_count():
		history.get_child(num).queue_free()
		num += 1
	for item in data:
		var h = history_item.instantiate()
		if typeof(item) != TYPE_STRING:
			h.date = item["history"]
			if item["item"].has("playing"):
				h.title = str(item["item"]["playing"]["song"]) + " by: " + str(item["item"]["playing"]["artist"])
				h.type = 1
				history.add_child(h)
			if item["item"].has("program_start"):
				h.title = str(item["item"]["program_start"])
				h.type = 2
				history.add_child(h)
			if item["item"].has("post"):
				h.title = str(item["item"]["post"]["title"])
				h.type = 0
				history.add_child(h)
			
