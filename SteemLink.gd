extends Control
#var OpenSeed = load("res://elements/OpenSeed.gd")
#var openseed = OpenSeed.new()
# Declare member variables here. Examples:
# var a = 2
# var b = "text"
signal linked

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _on_Link_pressed():
	$OpenSeed.loadUserData()
	$OpenSeed.steem = $Username.text
	$OpenSeed.postingkey = $postingkey.text
	$OpenSeed.saveUserData()
	emit_signal("linked")
	##queue_free()


func _on_Cancel_pressed():
	hide()
	pass # Replace with function body.
