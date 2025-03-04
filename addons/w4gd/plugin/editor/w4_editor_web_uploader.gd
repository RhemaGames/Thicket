@tool
extends Control

const W4EditorUtils = preload("w4_editor_utils.gd")

const WEB_BUILD_BUCKET = 'web'

@onready var export_preset_field: OptionButton = %ExportPresetField
@onready var build_name_field: LineEdit = %BuildNameField
@onready var build_slug_field: LineEdit = %BuildSlugField
@onready var debug_build_field: CheckBox = %DebugBuildField
@onready var public_build_field: CheckBox = %PublicBuildField

@onready var error_dialog: AcceptDialog = %ErrorDialog
@onready var error_message: Label = %ErrorMessage
@onready var error_details: TextEdit = %ErrorDetails

@onready var progress_window: Window = %ProgressWindow
@onready var progress_bar: ProgressBar = %ProgressBar
@onready var progress_message: Label = %ProgressMessage

var _profile: Dictionary
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
	error_dialog.visible = false
	progress_window.visible = false


func _update_export_presets() -> void:
	export_preset_field.clear()
	var i := 0
	var presets := W4EditorUtils.get_web_export_presets()
	for preset in presets:
		var export_name := "%s (%s)" % [preset.name, "threads" if preset.threads else "no threads"]
		export_preset_field.add_item(export_name)
		export_preset_field.set_item_metadata(i, preset)
		i += 1


func _on_upload_button_pressed():
	if export_preset_field.get_selected_id() == -1:
		_show_error("Must select an existing Web export preset.")
		return

	var build_name := build_name_field.text.strip_edges()
	if build_name == '':
		_show_error("Must enter a valid build name.")
		return

	var preset : W4EditorUtils.W4EditorPreset = export_preset_field.get_item_metadata(
		export_preset_field.get_selected_id()
	)
	var export_debug := debug_build_field.button_pressed

	if ! await W4EditorUtils.do_export_zip(preset, export_debug, _show_progress, _show_error):
		W4EditorUtils.clean_export_paths()
		return

	var slug := build_slug_field.text.strip_edges()
	var public := public_build_field.button_pressed

	if ! await _do_upload_and_create_build(build_name, slug, public):
		W4EditorUtils.clean_export_paths()
		return

	W4EditorUtils.clean_export_paths()
	_hide_progress()


func _do_upload_and_create_build(p_build_name: String, p_slug: String, p_public: bool) -> bool:
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

	var bucket := "web-builds"

	# Ensure the destination bucket exists.
	if bucket not in result.as_array().map(func (x): return x['name']):
		result = await sdk.client.storage.create_bucket(bucket).async()
		if result.is_error():
			_show_error("Unable to create storage bucket: " + str(result))
			return false

	result = await sdk.client.storage.upload_object(bucket, p_build_name.uri_encode() + '.zip', zip_data).async()
	if result.is_error():
		_show_error("Unable to upload ZIP file: " + str(result))
		return false

	_show_progress(95, "Creating the new build in the database...")

	var data := {
		slug = p_slug,
		name = p_build_name,
		object_id = result.Id.as_string(),
		public = p_public,
	}
	result = await sdk.client.rest.rpc("w4online.web_build_create", data).async()
	if result.is_error():
		_show_error("Unable to create build in the database: " + str(result))
		return false

	return true


func _on_visibility_changed():
	if sdk == null:
		return
	refresh()
