@tool
extends Control

var sdk : W4Client

signal run_script(script_path: String)

@onready var script_line_edit := $Run/HBoxContainer/ScriptLineEdit as LineEdit
@onready var script_picker_button := $Run/HBoxContainer/ScriptPickerButton as Button
@onready var run_confirm_dialog := $RunConfirm as ConfirmationDialog
@onready var script_picker := $ScriptPicker as FileDialog
@onready var run_confirm_details := $RunConfirm/VBoxContainer/RunConfirmDetails as Label
@onready var error_dialog := $ErrorDialog as AcceptDialog

func _ready():
	if not Engine.is_editor_hint():
		refresh()


func refresh():
	if has_theme_icon("Script", "EditorIcons"):
		script_picker_button.icon = get_theme_icon("Script", "EditorIcons")


func _on_script_picker_file_selected(path):
	script_line_edit.text = path


func _pick_file():
	script_picker.popup_centered(Vector2i(500, 400))


func _on_run_button_pressed():
	var script : String = script_line_edit.text.strip_edges()
	if not FileAccess.file_exists(script):
		_error("Invalid File Name.\nUnable to run '%s'" % script)
		return
	if sdk == null:
		_error("SDK not set!")
		return
	run_confirm_details.text = "URL: '%s'\nPath: '%s'\n" % [sdk.client.client.base_url, script]
	run_confirm_dialog.popup_centered(Vector2(400, 200))
	run_confirm_dialog.get_cancel_button().grab_focus()


func _on_run_confirmed():
	run_script.emit(script_line_edit.text.strip_edges())


func _error(message, min_size:=Vector2i(300, 100)):
	error_dialog.dialog_text = message
	error_dialog.exclusive = true
	error_dialog.popup_centered(min_size)


func _on_visibility_changed():
	if not is_visible_in_tree() or sdk == null:
		return
	refresh()
