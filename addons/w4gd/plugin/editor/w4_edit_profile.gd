@tool
extends Panel

signal profile_saved(is_new: bool, profile: Dictionary)
signal cancelled()

var is_new := false
var additional_check: Callable

func edit_profile(p_profile:Dictionary, p_additional_check: Callable) -> void:
	assert(p_profile.has("name"))
	assert(p_profile.has("url"))
	assert(p_profile.has("key"))
	%NameLineEdit.text = p_profile["name"]
	%NameLineEdit.editable = p_profile["name"] != "default"
	%URLLineEdit.text = p_profile["url"]
	%KeyLineEdit.text = p_profile["key"]
	%ErrorLabel.hide()
	is_new = false
	additional_check = p_additional_check
	show()

func new_profile(p_additional_check: Callable) -> void:
	%NameLineEdit.text = "New profile"
	%NameLineEdit.editable = true
	%URLLineEdit.text = ""
	%KeyLineEdit.text = ""
	%NameLineEdit.select_all()
	%NameLineEdit.grab_focus()
	%ErrorLabel.hide()
	is_new = true
	additional_check = p_additional_check
	show()

func _on_cancel_button_pressed() -> void:
	cancelled.emit()
	hide()

func _on_save_button_pressed() -> void:
	var profile = {"name": %NameLineEdit.text, "url": %URLLineEdit.text, "key": %KeyLineEdit.text}
	if profile["name"].is_empty():
		%ErrorLabel.text = "Name cannot be empty"
		%ErrorLabel.show()
		return
	if profile["url"].is_empty():
		%ErrorLabel.text = "URL cannot be empty"
		%ErrorLabel.show()
		return
	if profile["key"].is_empty():
		%ErrorLabel.text = "Key cannot be empty"
		%ErrorLabel.show()
		return
	var result = additional_check.call(profile)
	if result:
		%ErrorLabel.text = str(result)
		%ErrorLabel.show()
		return
	profile_saved.emit(is_new, profile)
	hide()
