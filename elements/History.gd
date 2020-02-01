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
	#SocialRoot.get_node("history_update").start()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_history_update_timeout():
	var history 
	if SocialRoot.currentuser:
		#print("Current User "+SocialRoot.currentuser)
		history = OpenSeed.get_history(SocialRoot.currentuser)
	else:
		history = OpenSeed.get_history(OpenSeed.username)
	if history:
		#get_node("VBoxContainer/RichTextLabel2").text = history
		history(history.split("\n"))
		
	SocialRoot.get_node("history_update").wait_time = 120
	pass 
	
func history(data):

	for item in data:
		var h = history_item.instance()
		if len(item) > 5:
			var jsoned = parse_json(item)
			h.date = jsoned["history"]
			if jsoned["item"].has("playing"):
				h.title = str(jsoned["item"]["playing"])
				h.type = 1
				$VBoxContainer/ScrollContainer/VBoxContainer.add_child(h)
			if jsoned["item"].has("program_start"):
				h.title = str(jsoned["item"]["program_start"])
				h.type = 2
				$VBoxContainer/ScrollContainer/VBoxContainer.add_child(h)
			
