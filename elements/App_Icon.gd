extends Control

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var imgfile = File.new()
var file = File.new()
var title = "App"
var icon = "none"
var path = ""
var exec = ""
signal execute(program)
# Called when the node enters the scene tree for the first time.
func _ready():
	read_destop(path)
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func read_destop(path):
	file.open(path,File.READ)
	var info = file.get_as_text()
	var appName = ""
	var iconName = ""
	var execName = ""
	for data in info.split("\n"):
		if len(data.split("=")) > 1:
			var opt = data.split("=")[0]
			var val = data.split("=")[1]
			if opt == "NoDisplay":
				queue_free()
			if opt == "NotShowIn":
				queue_free()
			if opt == "Categories":
				for type in ["Office","Utility","Settings","System","AudioVideo","Screensaver","Graphics"]:
					if val.find(type) != -1:
						queue_free()
			if opt == "Name":
				if appName == "":
					appName = val
					$Label.text = val
			if opt == "Icon":
				if iconName == "":
					iconName = val
					$TextureRect.set_texture(get_pic(find_icon(val)))
			if opt == "Exec":
				if execName == "":
					execName = val
					exec = val
	file.close()
	if exec == "":
		queue_free()
		
	pass

func find_icon(iconname):
	var iconpath = ""
	var dir = Directory.new()
	var places = ["/usr/share/icons/hicolor/scalable/apps","/usr/share/applications/icons/hicolor/256x256/apps","/usr/share/applications/icons/hicolor/128x128/apps","/usr/share/icons/Pop/128x128/apps","/usr/share/app-info/icons/pop-artful-extra/64x64","/usr/share/pixmaps","/usr/share/applications/icons/hicolor/64x64/apps",
	"user://../../../icons/hicolor/scalable/apps","user://../../../icons/hicolor/256x256/apps","user://../../../icons/hicolor/128x128/apps","user://../../../icons/hicolor/64x64/apps","/usr/share/app-install/icons"]
	
	for place in places:
		if dir.dir_exists(place):
			dir.open(place)
			dir.list_dir_begin()
			var file_name = dir.get_next()
			while (file_name != ""):
				if str(file_name.split(".")[0]).to_lower() == iconname.to_lower():
					iconpath = place+"/"+file_name
					break
				file_name = dir.get_next()
	return iconpath

func _on_App_Icon_mouse_entered():
	$highlight.visible = true
	pass # Replace with function body.


func _on_App_Icon_mouse_exited():
	$highlight.visible = false
	pass # Replace with function body.

func get_pic(img) :
	var Imagetex = ImageTexture.new()
	var Imagedata = Image.new()
	if imgfile.file_exists(img):
		imgfile.open(img, File.READ)
		var imagesize = imgfile.get_len()
		var err = Imagedata.load_jpg_from_buffer(imgfile.get_buffer(imagesize))
		if err:
			err = Imagedata.load_png_from_buffer(imgfile.get_buffer(imagesize))
		if err:
			Imagedata.load(img)
		imgfile.close()
	else:
		Imagedata.load("res://Img/leaf.svg")
		
	Imagetex.create_from_image(Imagedata,0)
	return Imagetex

func _on_App_Icon_gui_input(event):
	if event is InputEventMouseButton and event.pressed and Input.is_mouse_button_pressed(1): 
		emit_signal("execute",exec)
	pass # Replace with function body.
