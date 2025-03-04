extends EditorExportPlugin

signal export_being()
signal export_end()

func _export_begin(features, is_debug, path, flags):
	export_being.emit()

func _export_end():
	export_end.emit()


func _get_name():
	return "W4ExportPlugin"
