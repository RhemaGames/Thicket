@tool
extends Control

const W4EditorServers = preload("w4_server_uploader.gd")
const W4EditorWeb = preload("w4_editor_web_uploader.gd")
const W4EditorDatabase = preload("w4_editor_database.gd")

const ADMIN_ROLE := "service_role"
const SIDEBAR_BUTTONS := [&"Home", &"Servers", &"Web", &"Database"]

var sdk: W4Client : set = _set_sdk
var editor_scale := 1.0 : set = _set_editor_scale
var sidebar_btn_group := ButtonGroup.new()

@onready var auth_helper := $W4AuthHelper as W4AuthHelper
@onready var tab_container := $%Main/MarginContainer/HSplitContainer/TabContainer as TabContainer
@onready var servers := $%Main/MarginContainer/HSplitContainer/TabContainer/Servers/VBoxContainer/Servers as W4EditorServers
@onready var database := $%Main/MarginContainer/HSplitContainer/TabContainer/Database/VBoxContainer/Database as W4EditorDatabase
@onready var web := $%Main/MarginContainer/HSplitContainer/TabContainer/Web/VBoxContainer/Web as W4EditorWeb
@onready var theme_provider := $%ThemeProvider as HBoxContainer
@onready var auth_ui := $%Auth as Control
@onready var main_ui := $%Main as Control
@onready var sidebar_button_container := $%Sidebar/VBoxContainer/Buttons as VBoxContainer
@onready var auth_error_label := $%ErrorLabel as Label
@onready var auth_email_input := $%EmailInput as LineEdit
@onready var auth_password_input := $%PasswordInput as LineEdit
@onready var web_dashboard_link := $%Auth/LoginScreen/Vertical/Web/LinkButton as LinkButton
@onready var home_web_dashboard_link := $%Main/MarginContainer/HSplitContainer/TabContainer/Home/VBoxContainer/Web/LinkButton as LinkButton
@onready var settings_button: MenuButton = %SettingsButton
@onready var w_4_edit_profile := %W4EditProfile
@onready var profiles_option_button: OptionButton = %ProfilesOptionButton
@onready var confirm_delete_profile_dialog: ConfirmationDialog = %ConfirmDeleteProfileDialog

# Profiles.
var _current_profile := "default"
var _profiles := [
#	{
#		"name": "internal",
#		"url": "test",
#		"key": "testkey"
#	}
]
signal profiles_modified(profiles: Array)
signal profile_selected(profile: String)

func set_profile_list(p_profiles):
	_profiles = p_profiles
	_update_profiles_option_button()
	_update_settings_button()


func set_current_profile(p_current_profile : String):
	assert(_profiles.filter(func(e): return e.name == p_current_profile).size(), "No profile found with ID: %s" % p_current_profile)
	if (p_current_profile == _current_profile):
		return
	_current_profile = p_current_profile
	profile_selected.emit(_current_profile)
	_update_profiles_option_button()
	_update_settings_button()
	_update_dashboard_link()


func get_config():
	var found = _profiles.filter(func(e): return e.name == _current_profile)
	if found.size():
		return found.front()
	assert(false)


func _ready():
	_set_sdk(sdk)
	sidebar_btn_group.pressed.connect(_sidebar_button_pressed)
	if not Engine.is_editor_hint():
		_set_editor_scale(editor_scale)

func _notification(what):
	if sdk == null:
		return
	if what == NOTIFICATION_THEME_CHANGED:
		_update_theme()


#region Workspace profiles

func _profile_settings_index_pressed(index : int):
	if index == 0: # Edit.
		w_4_edit_profile.edit_profile(get_config(),
			func (edited_profile):
				if _profiles.filter(func (x): return x["name"] == edited_profile["name"] and x["name"] != _current_profile).size():
					return "A profile with this name already exists"
		)
	elif index == 1: # New.
		w_4_edit_profile.new_profile(
			func (new_profile):
				if _profiles.filter(func (x): return x["name"] == new_profile["name"]).size():
					return "A profile with this name already exists"
		)
	elif index == 2: # Delete.
		confirm_delete_profile_dialog.popup_centered()


func _on_profiles_option_button_item_selected(index: int) -> void:
	set_current_profile(_profiles[index]["name"])


func _on_w_4_edit_profile_profile_saved(p_is_new: bool, p_profile: Dictionary) -> void:
	if p_is_new:
		assert(p_profile["name"] != "default")
		_current_profile = p_profile["name"]
		_profiles.append(p_profile)
		profiles_modified.emit(_profiles)
		profile_selected.emit(_current_profile)
	else:
		for index in range(_profiles.size()):
			if _profiles[index]["name"] == _current_profile:
				_profiles[index] = p_profile
				_current_profile = p_profile["name"]
				profiles_modified.emit(_profiles)
				profile_selected.emit(_current_profile)
				break
	_update_profiles_option_button()
	_update_dashboard_link()


func _update_profiles_option_button():
	profiles_option_button.clear()
	for index in range(_profiles.size()):
		var profile = _profiles[index]
		profiles_option_button.add_item("%s (%s)" % [profile["name"], profile["url"]])
		if _current_profile == profile["name"]:
			profiles_option_button.select(index)


func _update_settings_button():
	settings_button.get_popup().set_item_disabled(2, _current_profile == "default")


#endregion


func _set_sdk(value: W4Client):
	sdk = value
	if auth_helper != null:
		auth_helper.sdk = sdk
	if servers != null:
		servers.sdk = sdk
	if database != null:
		database.sdk = sdk
	if web != null:
		web.sdk = sdk
	_update_login_state()
	_update_dashboard_link()

	if sdk == null:
		return

	# Use the TabContainer's theme for the panels.
	settings_button.get_popup().index_pressed.connect(_profile_settings_index_pressed)
	_update_theme()
	_update_profiles_option_button()
	_update_settings_button()
	_update_sidebar()


func _set_editor_scale(value: float):
	editor_scale = value
	var min_size = Vector2(400, 0) * editor_scale
	if main_ui != null:
		main_ui.custom_minimum_size = min_size
	if auth_ui != null:
		auth_ui.custom_minimum_size = min_size


func _update_sidebar():
	for btn in sidebar_button_container.get_children():
		if btn.name in SIDEBAR_BUTTONS:
			btn.button_group = sidebar_btn_group


func _update_login_state():
	if sdk == null or auth_ui == null or main_ui == null:
		return
	if sdk.identity.role == ADMIN_ROLE:
		auth_ui.hide()
		main_ui.show()
	else:
		auth_ui.show()
		main_ui.hide()
		auth_email_input.text = ""
		auth_password_input.text = ""


func _on_visibility_changed():
	if sdk == null:
		return
	_update_login_state()
	if is_visible_in_tree() and _current_profile == "default":
		var cfg = get_config()
		if cfg.url == "" or cfg.key == "":
			_profile_settings_index_pressed(0)


func _on_w_4_auth_helper_logged_out():
	auth_error_label.text = ""
	_update_login_state()


func _on_w_4_auth_helper_logged_in():
	var msg = "" if sdk.identity.role == ADMIN_ROLE else "Invalid user role: '%s'" % sdk.identity.role
	_set_login_message(msg, not msg.is_empty())
	_update_login_state()


func _set_login_message(message: String, error:=true):
	auth_error_label.text = message
	var color = Color.DARK_RED if error else Color.DARK_GREEN
	auth_error_label.add_theme_color_override("font_color", color)


func _on_login_input_submitted(_unused = ""):
	_set_login_message("Logging in...", false)
	auth_helper.login_email(
		auth_email_input.text,
		auth_password_input.text
	)


func _sidebar_button_pressed(btn: BaseButton):
	var tab := SIDEBAR_BUTTONS.find(btn.name)
	if tab == -1:
		return
	tab_container.current_tab = tab


func _on_logout_pressed():
	auth_helper.logout()


func _update_dashboard_link():
	if sdk == null or web_dashboard_link == null:
		return
	var url := sdk.client.get_rest_client().base_url
	if url.is_empty():
		web_dashboard_link.uri = url
		home_web_dashboard_link.uri = url
		return
	if not url.begins_with("http://") and not url.begins_with("https://"):
		url = "http://" + url
	url = url.trim_suffix("/") + "/dashboard/"
	web_dashboard_link.uri = url
	home_web_dashboard_link.uri = url


func _update_theme():
	if !theme_provider:
		return
	if theme_provider.theme == null:
		theme_provider.theme = Theme.new()
		theme_provider.theme.add_type("Panel")
	theme_provider.theme.set_stylebox("panel", "Panel", get_theme_stylebox("panel", "TabContainer"))

	# Set icons for setting button
	%SettingsButton.icon = get_theme_icon("Tools", "EditorIcons")

	# Set the icons for the profiles options.
	settings_button.get_popup().set_item_icon(0, get_theme_icon("Edit", "EditorIcons"))
	settings_button.get_popup().set_item_icon(1, get_theme_icon("New", "EditorIcons"))
	settings_button.get_popup().set_item_icon(2, get_theme_icon("Remove", "EditorIcons"))


func _on_confirm_delete_profile_dialog_confirmed() -> void:
	assert(_current_profile != "default")
	for i in range(_profiles.size()):
		if _profiles[i]["name"] == _current_profile:
			_profiles.pop_at(i)
			break
	profiles_modified.emit(_profiles)
	set_current_profile("default")
