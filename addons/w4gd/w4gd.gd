extends W4Client

const GameServerSDK = preload("game_server/game_server_sdk.gd")

var game_server: GameServerSDK
var service : W4Client

func has_service() -> bool:
	return service != null


func _init():
	super()
	if W4ProjectSettings.has_servers():
		game_server = GameServerSDK.new()
		game_server.name = 'GameServerSDK'
		add_child(game_server)


func _ready() -> void:
	if client != null:
		client.realtime.connection_error.connect(_on_realtime_connection_error)
		connect_to_realtime()


func _on_realtime_connection_error():
	if client.realtime.should_retry_connection():
		print("Realtime disconnected, retrying...")
	else:
		print("Realtime disconnected.")
