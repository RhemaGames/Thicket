extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var minNum = 0
var maxNum = 7
var currentNum = 0
var startRotation = -180
var currentRotation = 0
var title = ""
var num = 0

# warning-ignore:unused_signal
signal set_num(number)
# Called when the node enters the scene tree for the first time.
func _ready():
	title = "Connections"
	$Info/VBoxContainer/statTitle.text = title
	$Info/VBoxContainer/StatNumber.text = str(num)
	$Indicator.rotation = startRotation
# warning-ignore:return_value_discarded
	OpenSeed.connect("conversations", Callable(self, "_on_conversations_update"))



# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
	#$Indicator.rect_rotation = startRotation
	#startRotation += 1
	#pass

func _on_StatCircle_set_num(number):
	$Indicator.rotation = startRotation+number
	num = startRotation+number
	$Info/VBoxContainer/StatNumber.text = str(number)
	

func _on_conversations_update(_data):
	var number = 0
	if typeof(Thicket.connections_list) == TYPE_ARRAY:
		number = len(Thicket.connections_list)
	emit_signal("set_num",number)
