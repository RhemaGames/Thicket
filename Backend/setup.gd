extends CanvasLayer

## First-boot setup, shown while this device has no owner. Someone at the machine logs in through the
## Thicket service and claims it for a company and location, and the network settings are saved as the
## device settings. Companies and locations are made on the Dashboard.

@onready var panels = [$Welcomne, $Network, $Owner, $Device]
@onready var connection = $Network/VBoxContainer/settingContainer/Connection
@onready var connection_type = $Network/VBoxContainer/settingContainer/ConnectionType
@onready var owner_form = $Owner/VBoxContainer/VBoxContainer
var logged_in := false
var place := PanelContainer.new()
var place_info := Label.new()
var company_pick := OptionButton.new()
var location_pick := OptionButton.new()
var companies:Array = []
var locations:Array = []

func _ready() -> void:
	_show(null)
	owner_form.get_node("Passphrase/entry").secret = true
	connection_type.get_node("WifiOpts/WifiPassword/Password").secret = true
	$Welcomne/VBoxContainer/Control/Welcome.pressed.connect(_show.bind($Network))
	$Network/VBoxContainer/Control/Next.pressed.connect(_show.bind($Owner))
	$Network/VBoxContainer/Control/Cancel.pressed.connect(_show.bind(null))
	owner_form.get_node("HBoxContainer/Button").pressed.connect(_on_connect_pressed)
	$Owner/VBoxContainer/Control/Back.pressed.connect(_show.bind($Network))
	_build_place()
	$Owner/VBoxContainer/Control/Continue.pressed.connect(func():
		if logged_in:
			_show(place)
			Service.request_companies())
	$Device/VBoxContainer/Control/Back.pressed.connect(_show.bind(place))
	$Device/VBoxContainer/Control/Finish.pressed.connect(_on_finish_pressed)
	Service.from_peer.connect(_on_from_peer)
	Service.auth.connect(_on_auth)

## The company and location panel.
func _build_place() -> void:
	add_child(place)
	panels.insert(3, place)
	place.custom_minimum_size = Vector2(480, 0)
	place.set_anchors_and_offsets_preset(Control.PRESET_CENTER, Control.PRESET_MODE_MINSIZE)
	place.grow_horizontal = Control.GROW_DIRECTION_BOTH
	place.grow_vertical = Control.GROW_DIRECTION_BOTH
	var box = VBoxContainer.new()
	place.add_child(box)
	var title = Label.new()
	title.text = "Who owns this machine?"
	box.add_child(title)
	box.add_child(company_pick)
	box.add_child(location_pick)
	place_info.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	box.add_child(place_info)
	var buttons = HBoxContainer.new()
	box.add_child(buttons)
	var back = Button.new()
	back.text = "Back"
	back.pressed.connect(_show.bind($Owner))
	buttons.add_child(back)
	var next = Button.new()
	next.text = "Continue"
	next.pressed.connect(func():
		if location_pick.selected >= 0:
			_show($Device))
	buttons.add_child(next)
	company_pick.item_selected.connect(func(i): Service.request_locations(int(companies[i].id)))

func _show(panel) -> void:
	for p in panels:
		p.visible = p == panel

func _on_from_peer(_id, type, data) -> void:
	match type:
		"hello":
			Service.get_system_config()
		"system_config":
			if str(data.get("owner_id", "")) != "":
				return
			connection.get_node("local").button_pressed = data.get("network_local", false)
			connection.get_node("internet").button_pressed = data.get("network_internet", false)
			connection_type.get_node("wifi").button_pressed = data.get("network_wireless", false)
			connection_type.get_node("wired").button_pressed = data.get("network_wired", false)
			connection_type.get_node("WifiOpts/WifiSSID/NetworkName").text = str(data.get("network_ssid", ""))
			_show($Welcomne)
		"system_config_saved":
			_show(null)
		"companies":
			companies = data
			company_pick.clear()
			location_pick.clear()
			for c in companies:
				company_pick.add_item(str(c.company_name))
			place_info.text = "Create your company on the Dashboard first, then come back." if companies.is_empty() else ""
			if !companies.is_empty():
				Service.request_locations(int(companies[company_pick.selected].id))
		"locations":
			locations = data.locations
			location_pick.clear()
			for l in locations:
				location_pick.add_item(str(l.location_name))
			place_info.text = "Add a location on the Dashboard first, then come back." if locations.is_empty() else ""
		"arcade_claimed":
			Service.set_system_config(_network_settings())

func _on_connect_pressed() -> void:
	owner_form.get_node("info").text = "checking"
	Service.account_login(owner_form.get_node("Username/entry").text, owner_form.get_node("Passphrase/entry").text)

func _on_auth(type, data) -> void:
	match type:
		"login":
			logged_in = true
			owner_form.get_node("info").text = "Connected as " + Service.network_data.username
		"auth_error":
			logged_in = false
			owner_form.get_node("info").text = str(data)
		"logout":
			logged_in = false

func _on_finish_pressed() -> void:
	Service.arcade_claim(companies[company_pick.selected].uuid, locations[location_pick.selected].uuid)

func _network_settings() -> Dictionary:
	return {
		"network_local": connection.get_node("local").button_pressed,
		"network_internet": connection.get_node("internet").button_pressed,
		"network_wireless": connection_type.get_node("wifi").button_pressed,
		"network_wired": connection_type.get_node("wired").button_pressed,
		"network_ssid": connection_type.get_node("WifiOpts/WifiSSID/NetworkName").text,
		"network_password": connection_type.get_node("WifiOpts/WifiPassword/Password").text}
