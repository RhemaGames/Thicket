extends Panel

var title = ""
var date = ""
var type = 0


func _ready():
	match type:
		0:
			$HBoxContainer/TextureRect.texture = load("res://Img/folder-recent-symbolic.svg")
		1:
			$HBoxContainer/TextureRect.texture = load("res://Img/folder-music-symbolic.svg")
		2:
			$HBoxContainer/TextureRect.texture = load("res://Img/preferences-system-symbolic.svg")
			
	$HBoxContainer/VBoxContainer/title.text = title
	$HBoxContainer/VBoxContainer/date.text = date
	pass # Replace with function body.



