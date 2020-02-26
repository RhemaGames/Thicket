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
	OpenSeed.connect("historydata",self,"show_history")
	#SocialRoot.get_node("history_update").start()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_history_update_timeout():
	var history 
	if SocialRoot.currentuser:
		OpenSeed.emit_signal("command","history",SocialRoot.currentuser)
	else:
		OpenSeed.emit_signal("command","history",OpenSeed.username)
	pass 
	
func show_history(data):
	var history = $VBoxContainer/ScrollContainer/VBoxContainer
	var num = 0
	while num < history.get_child_count():
		history.get_child(num).queue_free()
		num += 1
	for item in data.keys():
		var h = history_item.instance()
		h.date = data[item]["history"]
		if data[item]["item"].has("playing"):
			h.title = str(data[item]["item"]["playing"])
			h.type = 1
			history.add_child(h)
		if data[item]["item"].has("program_start"):
			h.title = str(data[item]["item"]["program_start"])
			h.type = 2
			history.add_child(h)
			
