extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var minNum = 0
var maxNum = 7
var currentNum = 0
var startRotation = 0
var currentRotation = 0

signal set_num(number)
# Called when the node enters the scene tree for the first time.
func _ready():
	$Indicator.rect_rotation = startRotation
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	$Indicator.rect_rotation = startRotation
#	startRotation += 1
#	print($Indicator.rect_rotation)
#	pass

func _on_StatCircle_set_num(number):
	$Indicator.rect_rotation = number
	pass # Replace with function body.
