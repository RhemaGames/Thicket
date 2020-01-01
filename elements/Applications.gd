extends Control
var app_view = preload("res://elements/App_Icon.tscn")
# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var Thicket
var OpenSeed
# Called when the node enters the scene tree for the first time.
func _ready():
	Thicket = get_node("/root/Thicket")
	OpenSeed = get_node("/root/OpenSeed")
	Thicket.application_list()
	create_list()
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func create_list():
	for app in Thicket.applications:
		var av = app_view.instance()
		av.path = app
		av.connect("execute",self,"execute")
		$applicationList/ScrollContainer/GridContainer.add_child(av)
		
func execute(program):
	var prog = program.split(" ")
	var opts = []
	var num = 1
	while len(prog) > num:
		if prog[num] != "%u":
			opts.append(prog[num])
		num +=1
		
	print ("executing "+program)
	OS.execute(prog[0],opts,false)
	pass