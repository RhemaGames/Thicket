extends Panel

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var fallback_audio = preload("res://Img/folder-music-symbolic.svg")
var title = ""
var artist = ""
var block = ""
var post = ""
var texblock = ""
var img = ""
var the_img
var track = ""
var imgfile = File.new()
var textureList = []

signal play(track)
signal info(track)

func _ready():
	$artist.text = artist
	$title.text = title
	set_box(img)
# warning-ignore:return_value_discarded
	OpenSeed.connect("imagestored",self,"refresh")

func set_box(image):
	var imagehash = OpenSeed.get_image(image)
	if imagehash != "No_Image_found":
		var fromStore = OpenSeed.get_from_image_store(imagehash)
		if !fromStore:
			the_img = OpenSeed.set_image(imagehash)
		else:
			the_img = fromStore
		$TextureRect.set_texture(the_img)
		
func _on_MusicBoxMedium_gui_input(event):
	if event is InputEventMouseButton and !event.is_doubleclick() and event.is_pressed():
		emit_signal("info",[track,artist,title,img,post])
	if event is InputEventMouseButton and event.is_doubleclick():
		emit_signal("play",[track,artist,title,img,post])


func refresh():
	var imagehash = OpenSeed.get_image(img)
	if imagehash != "No_Image_found":
		#var texbox = TextureRect.new()
		var fromStore = OpenSeed.get_from_image_store(imagehash)
		if !fromStore:
			the_img = fallback_audio
		else:
			the_img = fromStore
		$TextureRect.set_texture(the_img)
