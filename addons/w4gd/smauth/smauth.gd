## The W4 Cloud custom authentication end-point at /idp/v1.
extends "../supabase/auth.gd"

const Endpoint = preload("../supabase/endpoint.gd")

const PROVIDER_DOMAIN = "*.anon.localhost"

## The custom authentication endpoint.
var idp : Endpoint

var _uuid := W4Utils.UUIDGenerator.new()

func _init(client, identity):
	super(client, "/auth/v1", identity)
	idp = Endpoint.new(client, "/idp/v1", identity)


func _idp_login(data):
	return begin_sso(
		PROVIDER_DOMAIN
	).then(func(result):
		if result.is_error():
			return result
		var split : PackedStringArray = result["url"].as_string().split("?")
		if split.size() < 2:
			return result
		var request_query = client.dict_from_query(split[1])
		return idp.POST("/sso", data, request_query)
	).then(func(result):
		if result.is_error():
			return result
		var dict : Dictionary = result.as_dict()
		if dict.has("access_token"):
			return _handle_login_response(result)
		elif dict.has("SAMLResponse"):
			return login_sso(result.as_dict())
		# This shouldn't happen!
		return result
	)


## Login using a device ID and key combination.
##
## Store the ID and key in the client to allow the client to reuse the same player.
##
## [param id] A randomly generated UUIDv4 to use a username.
##
## [param key] A randomly generated string to be use as password for future logins.
func login_device(id: String, key: String):
	return _idp_login({
		"provider": "device",
		"id": id,
		"key": key,
		"proxy": OS.get_name() == "Web",
	})


## Login using device specific information
func login_device_auto():
	var cfg := ConfigFile.new()
	var file := "user://w4credentials.cfg"
	if OS.is_debug_build():
		var args := OS.get_cmdline_args()
		var idx := args.find("--w4-test-user")
		if idx > 0 and idx + 1 < args.size():
			file = "user://w4credentials-%s.cfg" % args[idx + 1]
	var section := "w4credentials"
	if FileAccess.file_exists(file):
		cfg.load(file)
	if not cfg.has_section(section) or not cfg.has_section_key(section, "device_id"):
		cfg.set_value(section, "device_id", _uuid.generate_v4())
	if not cfg.has_section(section) or not cfg.has_section_key(section, "device_key"):
		cfg.set_value(section, "device_key", _uuid.generate_v4())
	cfg.save(file)
	return login_device(cfg.get_value(section, "device_id"), cfg.get_value(section, "device_key"))

## Login using a Steam auth token.
##
## This only work if steam login provider is enabled in the backend.
##
## [param identity] The identity used to generate the auth token. This can be
## any value that would identify your service/game.
##
## [param ticket] The hexadecimal-encoded binary of the authentication ticket returned
## by Steam's GetAuthTicketForWebApi SDK function.
## See https://partner.steamgames.com/doc/api/ISteamUser#GetAuthTicketForWebApi.
##
## Example usage with GodotSteam (https://godotsteam.com/).
## [codeblock]
##     # Request a web API ticket.
##     var identity = "my_godot_game"
##     var ticket_id = Steam.getAuthTicketForWebApi(identity)
##     assert(ticket_id != 0)
##
##     # Get the ticket for the response.
##     var res
##     var res_ticket_id = 0
##     while res_ticket_id != ticket_id:
##         res = await Steam.get_ticket_for_web_api
##         res_ticket_id = res[0]
##     assert(res[1] == 1) # Check if request was successful (result = 1).
##
##     var ticket_buffer = res[3]
##
##     # Login using token.
##     var response = await W4GD.auth.login_steam(identity, (ticket_buffer as PackedByteArray).hex_encode()).async()
## [/codeblock]
##
## Note: setting up GodotSteam requires more than this code snippet (some configuration
## and callbacks setup). Check out https://godotsteam.com/tutorials/initializing/ and
## https://godotsteam.com/tutorials/authentication/ for more information.
##
## Note: while GodotSteam is not a strict requirement for using this login method, a
## way to access the Steam SDK within Godot is required. Right now, GodotSteam is the
## easiest way to achieve this, so its usage is very recommanded.
func login_steam(identity: String, ticket: String):
	return _idp_login({
		"provider": "steam",
		"identity": identity,
		"ticket": ticket,
	})
