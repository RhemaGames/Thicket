extends Node
class_name W4AuthHelper
## W4 Auth helper node.
##
## Helper node for the of W4 Cloud player authentication functionalities.
## [br]
## Add it to your scene or as an autoload.
## [br]
## Use it to signup, login, or logout the user, and connect to signals to react
## to user authentication status changes.
## [br]
## [codeblock]
## extends Node
##
## @onready var auth := $W4AuthHelper as W4AuthHelper
##
## func _ready():
##     if auth.is_logged_in():
##         print("Already logged in")
##     else:
##         print("Logging in")
##         auth.login_device()
##
## func _on_w_4_auth_helper_logged_in():
##     print("Logged in")
##
## func _on_w_4_auth_helper_logged_out():
##     print("Logged out")
##
## func _on_w_4_auth_helper_login_error(message):
##     print("Login error: %s" % message)
##
## func _on_w_4_auth_helper_signup_succeeded(needs_verification: bool):
##     print("Signup succeeded. Needs verification: ", needs_verification)
##
## func _on_w_4_auth_helper_signup_error(message):
##     print("Signup error: %s" % message)
## [/codeblock]

## Emitted when a login request fails.
## [br]
## See [method login_email], [method login_device] and [method login_device_id].
signal login_error(message: String)

## Emitted when the user logs out.
## [br]
## Note: This is always emitted when a user logout is detected, even if the
##
## [method logout] method was not called on this instance directly.
signal logged_out()

## Emitted when the user logs in.
## [br]
## Note: This is always emitted when a user login is detected, even if the
## login function was not called on this instance directly.
signal logged_in()

## Emitted when a signup request fails.
## [br]
## See [method signup_email].
signal signup_error(message: String)

## Emitted when a signup request succeeds.
## [br]
## When [param needs_verification] is false, the user is automatically logged
## in, and [signal logged_in] will be emitted.
## [br]
## See [method signup_email].
signal signup_succeeded(needs_verification: bool)

var _request : W4Client.APIRequest = null

var _user_id := ""

## The W4 client to use.
## [br]
## Normally this is automatically set to the W4GD singleton during ready, but
## can be manually set to a custom instance if needed (e.g. for editor plugins
## or to support multiple logged in users in the same game instance).
var sdk : W4Client : set = _set_sdk

func _ready():
	# So it can be used safely as a @tool by providing your own instance
	if sdk == null:
		sdk = $/root/W4GD


func _exit_tree():
	_set_sdk(null)


func _set_sdk(value):
	if sdk == value:
		return
	_user_id = ""
	if sdk != null and is_instance_valid(sdk) and sdk.identity.identity_changed.is_connected(_identity_changed):
		sdk.identity.identity_changed.disconnect(_identity_changed)
	sdk = value
	if sdk != null:
		sdk.identity.identity_changed.connect(_identity_changed)
		_user_id = sdk.identity.uid


func _identity_changed():
	if _request != null:
		# Handled by request result callback
		_user_id = sdk.identity.uid
		return
	if _user_id == sdk.identity.uid:
		# Likely just a token refresh
		return
	_user_id = sdk.identity.uid
	if _user_id.is_empty():
		logged_out.emit()
	else:
		logged_in.emit()


## Cancel the currently pending request (if any).
func cancel() -> void:
	if _request == null:
		return
	_request.cancel()
	_request = null


func login_auto() -> void:
	cancel()
	# Try steam login.
	if Engine.has_singleton("Steam"):
		var steam = Engine.get_singleton("Steam")
		var inited : Dictionary = steam.steamInitEx(false)
		if inited.has("status") and inited["status"] == 0:
			var identity = ProjectSettings.get_setting("application/config/name")
			if identity == "":
				identity = "w4cloud"
			var steam_callback = steam.getAuthTicketForWebApi(identity)
			if steam_callback == 0:
				login_error.emit("Failed to request auth ticket from Steam.")
				return
			steam.get_ticket_for_web_api.connect(
				func(auth_ticket, result, ticket_size, ticket_buffer):
					if result != 1:
						login_error.emit("Failed to get auth ticket from Steam. Result: %d" % result)
						return
					login_steam(identity, ticket_buffer.hex_encode())
			)
			return
	# Fallback to Device ID login
	login_device()


## Login the user using Steam
func login_steam(identity: String, ticket_buffer: String) -> void:
	cancel()
	_request = sdk.auth.login_steam(identity, ticket_buffer).then(_login_result)
	_request.async()


## Login the user using information from this device.
## [br]
## Currently, this generates a random key/secret pair, store them in the user
## device, and use them for future logins.
func login_device() -> void:
	cancel()
	_request = sdk.auth.login_device_auto().then(_login_result)
	_request.async()


## Login the user using custom device informations.
## [br]
## This is similar to [method login_device] but you can manually specify the
## key/secret pair, and the credentials do not get automatically stored.
## [br]
## [param key] The device key to use for login.
## [br]
## [param secret] The device secret to use for login.
func login_device_id(key: String, secret: String) -> void:
	cancel()
	_request = sdk.auth.login_device(key, secret).then(_login_result)
	_request.async()


## Login the user using email and password.
## [br]
## [param email] The user email to use for login.
## [br]
## [param password] The user password to use for login.
func login_email(email: String, password: String) -> void:
	cancel()
	var stripped_mail := email.strip_edges()
	if stripped_mail.split("@", false).size() != 2:
		login_error.emit("Input Error: Invalid email")
		return
	if password.length() < 8:
		login_error.emit("Input Error: Password must be at least 8 characters long")
		return
	_request = sdk.auth.login_email(stripped_mail, password).then(_login_result)
	_request.async()


## Logs out the user.
func logout() -> void:
	sdk.auth.logout().async()


## Returns [code]true[/code] if the user is currently logged in.
func is_logged_in() -> bool:
	return not sdk.identity.uid.is_empty()


## Sign up the user using email.
## [br]
## When email verification is disabled, the user will be automatically logged
## in, and the [signal logged_in] signal will be emitted right after
## [signal signup_succeeded].
## [br]
## [param email] The user email to use for signup.
## [br]
## [param password] The user password to use for signup.
func signup_email(email: String, password: String) -> void:
	cancel()
	var stripped_mail := email.strip_edges()
	if stripped_mail.split("@", false).size() != 2:
		signup_error.emit("Invalid email")
		return
	if password.length() < 8:
		signup_error.emit("Password must be at least 8 characters long")
		return
	_request = sdk.auth.signup_email(stripped_mail, password).then(_signup_result)
	_request.async()


func _login_result(result: W4Client.APIResult):
	_request = null
	if result.is_error():
		login_error.emit(result.as_error().message)
		return result
	logged_in.emit()
	return result


func _signup_result(result: W4Client.APIResult):
	_request = null
	if result.is_error():
		signup_error.emit(result.as_error().message)
		return result
	# When email verification is not enabled, the user is automatically logged in.
	var is_login := result.as_dict().has("access_token") and not _user_id.is_empty()
	signup_succeeded.emit(not is_login)
	if is_login:
		logged_in.emit()
	return result
