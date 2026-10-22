extends CanvasLayer

## First-boot setup, shown while this device has no owner. The owner logs in through the
## Thicket service, and the network settings are saved as the device settings.

@onready var panels = [$Welcomne, $Network, $Owner, $Device]
@onready var connection = $Network/VBoxContainer/settingContainer/Connection
@onready var connection_type = $Network/VBoxContainer/settingContainer/ConnectionType
@onready var owner_form = $Owner/VBoxContainer/VBoxContainer
var logged_in := false

func _ready() -> void:
	_show(null)
	owner_form.get_node("Passphrase/entry").secret = true
	connection_type.get_node("WifiOpts/WifiPassword/Password").secret = true
	$Welcomne/VBoxContainer/Control/Welcome.pressed.connect(_show.bind($Network))
	$Network/VBoxContainer/Control/Next.pressed.connect(_show.bind($Owner))
	$Network/VBoxContainer/Control/Cancel.pressed.connect(_show.bind(null))
	owner_form.get_node("HBoxContainer/Button").pressed.connect(_on_connect_pressed)
	$Owner/VBoxContainer/Control/Back.pressed.connect(_show.bind($Network))
	$Owner/VBoxContainer/Control/Continue.pressed.connect(func():
		if logged_in:
			_show($Device))
	$Device/VBoxContainer/Control/Back.pressed.connect(_show.bind($Owner))
	$Device/VBoxContainer/Control/Finish.pressed.connect(_on_finish_pressed)
	Service.from_peer.connect(_on_from_peer)
	Service.auth.connect(_on_auth)

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
	Service.set_system_config({
		"network_local": connection.get_node("local").button_pressed,
		"network_internet": connection.get_node("internet").button_pressed,
		"network_wireless": connection_type.get_node("wifi").button_pressed,
		"network_wired": connection_type.get_node("wired").button_pressed,
		"network_ssid": connection_type.get_node("WifiOpts/WifiSSID/NetworkName").text,
		"network_password": connection_type.get_node("WifiOpts/WifiPassword/Password").text})
