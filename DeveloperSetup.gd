extends Control

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	$Panel/backButton.set("text","Cancel")
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_nextButton_pressed():
	if $Panel/Welcome.visible:
		$Panel/General.show()
		$Panel/Welcome.hide()
	elif $Panel/General.visible:
		#$Panel/nextButton.set("text","Finish")
		$Panel/General.hide()
		$Panel/Files.show()
		
	if !$Panel/Welcome.visible:
		$Panel/backButton.set("text","back")
	else:
		$Panel/backButton.set("text","Cancel")

func _on_backButton_pressed():
	if $Panel/General.visible:
		$Panel/General.hide()
		$Panel/Welcome.show()
		$Panel/backButton.set("text","Cancel")
	elif $Panel/Files.visible:
		$Panel/General.show()
		$Panel/Files.hide()
		
	elif $Panel/Welcome.visible:
		self.hide()
		
	if !$Panel/Welcome.visible:
		$Panel/backButton.set("text","Back")
	else:
		$Panel/backButton.set("text","Cancel")



func _on_Banner_pressed():
	$FileDialog.popup_centered_ratio()
	pass # Replace with function body.
