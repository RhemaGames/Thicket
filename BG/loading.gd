extends Node2D

const GameList = preload("res://elements/game_list.gd")

var current_bg = 0
var game_list

var initial_window_size
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Diagnosis loads the config and connects to the service before this runs.
	if Config.data.is_empty():
		Config.loaded.connect(_on_config_loaded, CONNECT_ONE_SHOT)
	else:
		$Timer.start()
	game_list = GameList.new()
	game_list.name = "GameList"
	add_child(game_list)
	get_window().size_changed.connect(screen_resize)
	initial_window_size = get_window().size
	if get_window().mode == 3:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	else:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_config_loaded():
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
	if event.is_action_pressed("Start"):
		game_list.toggle()

func change_background():
	var data = Config.data.get("shared", {}).get("Background", {}).get("Image", {}).get("data", {})
	if data.is_empty():
		return
	if current_bg < data.keys().size()-1:
		current_bg += 1
	else:
		current_bg = 0
	var image = Config.to_image(data[data.keys()[current_bg]])
	if image:
		$Sprite2D.texture = ImageTexture.create_from_image(image)

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

	
