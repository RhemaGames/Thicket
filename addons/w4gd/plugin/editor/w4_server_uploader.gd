@tool
extends Control

const EXPORT_PRESETS_PATH = 'res://export_presets.cfg'

const EXPORT_OUTPUT_PATH = 'res://.godot/w4cloud/export'
const EXPORT_ZIP_PATH = 'res://.godot/w4cloud/export.zip'

const GAMESERVER_BUCKET = 'gameservers'

const W4EditorUtils = preload("w4_editor_utils.gd")

@onready var export_preset_field: OptionButton = %ExportPresetField
@onready var build_name_field: LineEdit = %BuildNameField
@onready var debug_build_field: CheckBox = %DebugBuildField
@onready var fleet_field: OptionButton = %FleetField

@onready var error_dialog: AcceptDialog = %ErrorDialog
@onready var error_message: Label = %ErrorMessage
@onready var error_details: TextEdit = %ErrorDetails

@onready var progress_window: Window = %ProgressWindow
@onready var progress_bar: ProgressBar = %ProgressBar
@onready var progress_message: Label = %ProgressMessage

var sdk: W4Client

func _ready():
	if not Engine.is_editor_hint():
		refresh()


func _show_progress(p_amount: float, p_msg: String = "") -> void:
	progress_bar.value = p_amount

	progress_message.visible = not p_msg.is_empty()
	progress_message.text = p_msg

	progress_window.popup_centered(Vector2i(600, 100))


func _hide_progress() -> void:
	progress_window.visible = false


func _show_error(p_msg: String, p_details: String = "") -> void:
	_hide_progress()

	error_message.text = p_msg

	error_details.visible = not p_details.is_empty()
	error_details.text = p_details

	push_error(p_msg, p_details)
	error_dialog.popup_centered(Vector2i(600, 50 if p_details.is_empty() else 400))


func refresh() -> void:
	if not is_visible_in_tree() or sdk == null:
		return
	_update_export_presets()
	_update_fleet_options()
	error_dialog.visible = false
	progress_window.visible = false


func _update_export_presets() -> void:
	export_preset_field.clear()
	var presets := W4EditorUtils.get_server_exports_presets()

	var i := 0
	for preset in presets:
		export_preset_field.add_item(preset.name)
		export_preset_field.set_item_metadata(i, preset)
		i += 1


func _update_fleet_options() -> void:
	fleet_field.clear()
	fleet_field.add_item("- Don't update any fleet -", 0)
	fleet_field.set_item_metadata(0, {})
	fleet_field.selected = 0

	var result = await sdk.client.rest.GET("/fleet", {}, {'Accept-Profile': 'w4online'}).async()
	if result.is_error():
		print ("Error getting fleets: ", result)
		return

	var i := 1
	for fleet in result.as_array():
		fleet_field.add_item(fleet['description'], i)
		fleet_field.set_item_metadata(i, fleet)
		i += 1


func _on_upload_button_pressed():
	if export_preset_field.get_selected_id() == -1:
		_show_error("Must select an existing Linux export preset.")
		return

	var preset : W4EditorUtils.W4EditorPreset = export_preset_field.get_item_metadata(
		export_preset_field.get_selected_id()
	)
	var export_debug := debug_build_field.button_pressed

	var build_name := build_name_field.text.strip_edges()
	if build_name == '':
		_show_error("Must enter a valid build name.")
		return

	var fleet: Dictionary = fleet_field.get_selected_metadata()

	if ! await W4EditorUtils.do_export_zip(preset, export_debug, _show_progress, _show_error):
		W4EditorUtils.clean_export_paths()
		return

	if ! await _do_upload_and_create_build(build_name, fleet):
		W4EditorUtils.clean_export_paths()
		return

	W4EditorUtils.clean_export_paths()
	_hide_progress()


func _do_upload_and_create_build(p_build_name: String, p_fleet: Dictionary) -> bool:
	var zip_data = FileAccess.get_file_as_bytes(W4EditorUtils.EXPORT_ZIP_PATH)
	if zip_data.size() == 0:
		_show_error("Unable to load ZIP file into memory")
		return false

	var result

	_show_progress(75, "Uploading ZIP file to W4 Cloud... This may take awhile!")

	result = await sdk.client.storage.list_buckets().async()
	if result.is_error():
		_show_error("Unable to list storage buckets: " + str(result))
		return false

	# Ensure the destination bucket exists.
	if not GAMESERVER_BUCKET in result.as_array().map(func (x): return x['name']):
		result = await sdk.client.storage.create_bucket(GAMESERVER_BUCKET).async()
		if result.is_error():
			_show_error("Unable to create storage bucket: " + str(result))
			return false

	result = await sdk.client.storage.upload_object(GAMESERVER_BUCKET, p_build_name.uri_encode() + '.zip', zip_data).async()
	if result.is_error():
		_show_error("Unable to upload ZIP file: " + str(result))
		return false

	_show_progress(95, "Creating the new build in the database...")

	var data := {
		object_key = GAMESERVER_BUCKET + "/" + p_build_name + '.zip',
		name = p_build_name,
		props = {},
	}
	result = await sdk.client.rest.rpc("w4online.gameserver_build_create", data).async()
	if result.is_error():
		_show_error("Unable to create build in the database: " + str(result))
		return false

	if not p_fleet.is_empty():
		var fleet = p_fleet.duplicate(true)
		fleet.erase('cluster')
		fleet.erase('deleted')

		fleet['build_id'] = result.build_id
		fleet['image'] = null

		result = await sdk.client.rest.rpc("w4online.fleet_update", fleet).async()
		if result.is_error():
			_show_error("Unable to update fleet: " + str(result))
			return false

	return true


func _on_visibility_changed():
	if sdk == null:
		return
	refresh()
