extends Node2D

var current_bg = 0

var initial_window_size
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Config.open_config()
	Config.connect("loaded",Callable(self,"_on_config_loaded"))
	Config.connect("from_config",Callable(self,"_from_config"))
	get_window().size_changed.connect(screen_resize)
	initial_window_size = get_window().size

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_config_loaded():
	Service.connection_up = true
	$Timer.start()

func _on_from_config(_data):
	$Timer.start()

func _on_timer_timeout() -> void:
	#print(Config.data)
	call_deferred("change_background")

func _input(event):
	if event.is_action_pressed("ui_fullscreen"):
		if get_tree().root.mode != 3:
			get_tree().root.mode = 3
		else:
			get_tree().root.mode = 0

func change_background():
	var data = Config.data["shared"]["Background"]["Image"]["data"]
	if current_bg < data.keys().size()-1:
		current_bg += 1
	else:
		current_bg = 0
	var text = ImageTexture.create_from_image(data[data.keys()[current_bg]])	
	$Sprite2D.texture = text

func screen_resize():
	var screen_size = get_window().size
	$Camera2D.position = screen_size / 2
	$Diagnosis.position = screen_size / 2
	$Sprite2D.position = screen_size / 2
	$Clouds.position = screen_size / 2
	
	var x = float(screen_size.x) / float(initial_window_size.x)
	var y = float(screen_size.y) / float(initial_window_size.y)
	
	$Sprite2D.scale = Vector2(x,y)
	$Clouds.scale = Vector2(x,y) * 4
	if y <= x:
		$Diagnosis.scale = Vector2(y,y) * 0.6
	else:
		$Diagnosis.scale = Vector2(x,x) * 0.6
