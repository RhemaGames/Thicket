extends CanvasLayer

## Games installed on this arcade, from the Thicket service. Start toggles the list. Launching a
## game hides it until the game exits, and tells the service a session is running.

const RUNNER = "user://runners/godot_runner_linux"

var games:Array = []
var pid := -1
var grid := GridContainer.new()

func _ready() -> void:
	layer = 10
	visible = false
	var panel = PanelContainer.new()
	panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var scroll = ScrollContainer.new()
	grid.columns = 3
	grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(grid)
	panel.add_child(scroll)
	add_child(panel)
	Service.from_peer.connect(_on_from_peer)
	Service.local_service_connected.connect(func(up):
		if up:
			Service.request_games())

func toggle() -> void:
	if pid != -1:  # a game is running
		return
	visible = !visible
	if visible:
		Service.request_games()
		_focus_first()

func _unhandled_input(event:InputEvent) -> void:
	if visible and event.is_action_pressed("ui_cancel"):
		visible = false
		get_viewport().set_input_as_handled()

func _on_from_peer(_id, type, data) -> void:
	if type == "games":
		games = data
		_build()

func _build() -> void:
	for c in grid.get_children():
		c.queue_free()
	for g in games:
		var b = Button.new()
		b.text = g.name
		b.custom_minimum_size = Vector2(200, 200)
		b.icon = _icon(g.config)
		b.expand_icon = true
		b.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
		b.vertical_icon_alignment = VERTICAL_ALIGNMENT_TOP
		b.pressed.connect(launch.bind(g))
		grid.add_child(b)
	if visible:
		_focus_first.call_deferred()

func _focus_first() -> void:
	for c in grid.get_children():
		if !c.is_queued_for_deletion():
			c.grab_focus()
			return

## The first image anywhere in a game's catalog config, as a texture.
func _icon(config) -> Texture2D:
	var image = _first_image(config)
	return ImageTexture.create_from_image(image) if image else null

func _first_image(v) -> Image:
	var image = Config.to_image(v)
	if image:
		return image
	if v is Dictionary:
		v = v.values()
	if v is Array:
		for item in v:
			image = _first_image(item)
			if image:
				return image
	return null

func launch(game:Dictionary) -> void:
	var path = game.path
	var args = []
	if game.kind == "pck":
		args = ["--fullscreen", "--main-pack", path]
		path = ProjectSettings.globalize_path(RUNNER) if FileAccess.file_exists(RUNNER) else OS.get_executable_path()
	pid = OS.create_process(path, args)
	if pid == -1:
		push_error("Cannot start %s (%s)" % [game.name, path])
		return
	visible = false
	Service.session_start(game.rdns)

func _process(_delta:float) -> void:
	if pid != -1 and !OS.is_process_running(pid):
		pid = -1
		Service.session_end()
		visible = true
		_focus_first()
