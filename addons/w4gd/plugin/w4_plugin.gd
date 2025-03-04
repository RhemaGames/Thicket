@tool
extends EditorPlugin

const BASE = "w4games/w4rm"
const URL = "url"
const KEY = "key"
const PROFILES = "profiles"
const CURRENT_PROFILE = "current"

const W4ProjectSettings = preload("w4_project_settings.gd")

const W4PluginDashboardScene = preload("editor/w4_dashboard.tscn")
const W4PluginDashboardScript = preload("editor/w4_dashboard.gd")
const W4ExportPlugin = preload("editor/w4_export_plugin.gd")

# Icon
const W4Icon = preload("icons/w4icon.svg")

#region W4Debugger
class W4Debugger extends EditorDebuggerPlugin:

	var run_script_path := ""
	var run_script_data := {}

	func _has_capture(prefix) -> bool:
		return prefix == "w4"


	func _capture(message, data, session_id) -> bool:
		if message == "w4:ready":
			run_script(session_id)
			return true
		return false


	func run_script(session_id):
		if run_script_path.is_empty() or run_script_data.is_empty():
			return
		get_session(session_id).send_message("w4:run", [run_script_path, run_script_data.duplicate()])
		run_script_path = ""
		run_script_data.clear()
#endregion

#region ProjectSettings and Metadata

func _get_s(key, def=null):
	var fk = "%s/%s" % [BASE, key]
	return ProjectSettings.get_setting(fk) if ProjectSettings.has_setting(fk) else def


func _set_s(key, value):
	var fk = "%s/%s" % [BASE, key]
	ProjectSettings.set_setting(fk, value)


func _get_m(key, def=null):
	var es = get_editor_interface().get_editor_settings()
	return es.get_project_metadata("w4games", key, def)


func _set_m(key, value):
	var es = get_editor_interface().get_editor_settings()
	es.set_project_metadata("w4games", key, value)


func _check_set_metadata(key, value):
	if typeof(_get_m(key)) != typeof(value):
		_set_m(key, value)


func _init_settings():
	W4ProjectSettings.add_project_settings()

	_check_set_metadata(PROFILES, [])
	_check_set_metadata(CURRENT_PROFILE, "default")

#endregion

#region Profiles

func _get_profiles() -> Array:
	var profiles = _get_m(PROFILES, [])
	if typeof(profiles) == TYPE_ARRAY:
		profiles = profiles.duplicate(true)
	else:
		profiles = []
	profiles.push_front({
		"name" : "default",
		"url": ProjectSettings.get_setting("w4games/w4rm/url") as String,
		"key": ProjectSettings.get_setting("w4games/w4rm/key") as String,
	})
	return profiles


func _set_profiles(profiles: Array):
	for p in profiles:
		if "name" not in p or "url" not in p or "key" not in p:
			push_error("Invalid profile: %s" % [p])
			return
	_set_m(PROFILES, profiles.filter(func (p) : return p["name"] != "default"))
	var default_arr = profiles.filter(func (p) : return p["name"] == "default")
	assert(default_arr.size() == 1, "Profile list does not contain the \"default\" entry")
	var default = default_arr[0]
	_set_s("url", default["url"])
	_set_s("key", default["key"])


func _profiles_modified(p_profiles):
	_set_profiles(p_profiles)
	ProjectSettings.save()


func _profile_selected(profile: String):
	_set_m(CURRENT_PROFILE, profile)
	if sdk == null:
		return
	var config = dashboard_scene.get_config()
	sdk.client.client.base_url = config.url
	sdk.client.client.set_header("apikey", config.key)
	sdk.identity.set_access_token(config.key)
	OS.set_environment("W4_URL", config.url)
	OS.set_environment("W4_KEY", config.key)

#endregion

var debugger : W4Debugger
var dashboard_scene : W4PluginDashboardScript
var sdk : W4Client
var main_icon : Texture2D
var export_plugin : W4ExportPlugin
var export_restore_key := ""
var export_restore_url := ""

func _run_script(script_path):
	if dashboard_scene == null or sdk == null:
		return
	var config = dashboard_scene.get_config()
	debugger.run_script_path = script_path
	debugger.run_script_data = {"url": config["url"], "key": config["key"], "service_key": sdk.identity.access_token}
	var scene = dashboard_scene.scene_file_path.get_base_dir() + "/../w4_script_loader.tscn"
	get_editor_interface().play_custom_scene(scene)


func _customize_export_begin():
	# Customize the exported project to use the selected profile.
	assert(dashboard_scene != null)
	var config = dashboard_scene.get_config()
	export_restore_url = _get_s("url", "")
	export_restore_key = _get_s("key", "")
	_set_s("url", config["url"])
	_set_s("key", config["key"])


func _customize_export_end():
	# Restore the "default" profile project settings.
	assert(dashboard_scene != null)
	_set_s("url", export_restore_url)
	_set_s("key", export_restore_key)


#region PluginOverrides

func _enter_tree() -> void:
	_init_settings()

	add_autoload_singleton("W4GD", "res://addons/w4gd/w4gd.gd")

	var icon = _get_plugin_icon()
	add_custom_type("W4AuthHelper", "Node", W4AuthHelper, icon)
	add_custom_type("W4LobbyHelper", "Node", W4LobbyHelper, W4Icon)

	sdk = W4Client.new()
	add_child(sdk)

	debugger = W4Debugger.new()
	add_debugger_plugin(debugger)

	export_plugin = W4ExportPlugin.new()
	export_plugin.export_being.connect(_customize_export_begin)
	export_plugin.export_end.connect(_customize_export_end)
	add_export_plugin(export_plugin)

	dashboard_scene = W4PluginDashboardScene.instantiate()
	dashboard_scene.hide()
	get_editor_interface().get_editor_main_screen().add_child(dashboard_scene)
	dashboard_scene.sdk = sdk
	dashboard_scene.editor_scale = get_editor_interface().get_editor_scale()
	dashboard_scene.database.run_script.connect(_run_script)
	dashboard_scene.profiles_modified.connect(_profiles_modified)
	dashboard_scene.profile_selected.connect(_profile_selected)
	# Must be set after signal connections so we also update the sdk credentials if needed.
	dashboard_scene.set_profile_list(_get_profiles())
	dashboard_scene.set_current_profile(_get_m(CURRENT_PROFILE, "default"))

func _has_main_screen():
	return true


func _make_visible(visible):
	if dashboard_scene == null:
		return
	dashboard_scene.visible = visible


func _get_plugin_name():
	return "W4 Cloud"


func _get_plugin_icon():
	if main_icon != null:
		return main_icon
	main_icon = ImageTexture.create_from_image(W4Icon.get_image())
	main_icon.set_size_override(Vector2i(16, 16))
	return main_icon


func _exit_tree() -> void:
	remove_custom_type("W4AuthHelper")
	remove_debugger_plugin(debugger)
	remove_export_plugin(export_plugin)
	if dashboard_scene != null:
		dashboard_scene.queue_free()
		dashboard_scene = null

	if sdk != null:
		sdk.queue_free()
		sdk = null


#endregion
