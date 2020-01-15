extends Control

var app_view = preload("res://elements/App_Icon.tscn")
var LoadingScreen 
# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var Thicket
var OpenSeed
var pid = 0
var executing = ""
# Called when the node enters the scene tree for the first time.
func _ready():
	Thicket = get_node("/root/Thicket")
	OpenSeed = get_node("/root/OpenSeed")
	Thicket.application_list()
	create_list()
	LoadingScreen = get_node("/root/MainWindow/Loading")
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if pid != 0:
		LoadingScreen.get_node("Label").text = "Launched "+executing+"("+str(pid)+")"
		process_watcher(pid,executing)
		
	pass

func create_list():
	for app in Thicket.applications:
		var av = app_view.instance()
		av.path = app
		av.connect("execute",self,"execute")
		$applicationList/ScrollContainer/GridContainer.add_child(av)
		
func execute(program):
	LoadingScreen.show()
	var prog = program.split(" ")
	var opts = []
	var num = 1
	while len(prog) > num:
		if prog[num] != "%u" or prog[num] != "%U":
			opts.append(prog[num])
		num +=1
	LoadingScreen.get_node("Label").text = "Launching "+prog[0]
	OpenSeed.set_history("program_start",prog[0])
	if LoadingScreen.visible == true:
		print("ready to launch "+prog[0])
		print ("executing "+prog[0] +" with "+str(opts))
		pid = OS.execute(prog[0],opts,false)
		executing = prog[0]
	pass

func process_watcher(thepid,program):
	var output = []
	if OS.get_name() == "X11":
		OS.execute("/bin/ps",["--no-headers",str(thepid)],true,output)
		if len(output[0]) > 10 and output[0].find("<defunct>") != -1:
			pid = 0
			executing = ""
			OpenSeed.set_history("program_stop",program)
			LoadingScreen.hide()
