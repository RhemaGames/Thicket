extends Node

const EXPORT_PRESETS_PATH = 'res://export_presets.cfg'
const EXPORT_OUTPUT_PATH = 'res://.godot/w4cloud/export'
const EXPORT_ZIP_PATH = 'res://.godot/w4cloud/export.zip'

class W4EditorPreset extends RefCounted:

	var name := ""
	var platform := ""
	var is_dedicated := false
	var threads := true

	func _to_string():
		return "Preset<name=%s, platform=%s, is_dedicated=%s>" % [
			name,
			platform,
			is_dedicated
		]


static func get_presets() -> Array[W4EditorPreset]:
	var presets : Array[W4EditorPreset] = []
	var file := ConfigFile.new()
	if file.load(EXPORT_PRESETS_PATH) != OK:
		return presets
	for section in file.get_sections():
		if not file.has_section_key(section, 'name'):
			continue
		var preset := W4EditorPreset.new()
		preset.name = str(file.get_value(section, 'name'))
		preset.platform = str(file.get_value(section, 'platform'))
		preset.is_dedicated = str(file.get_value(section, 'dedicated_server', false)) == "true"
		var options := section + ".options"
		preset.threads = str(file.get_value(options, 'variant/thread_support', true)) == "true"
		presets.push_back(preset)
	return presets


static func get_server_exports_presets() -> Array[W4EditorPreset]:
	var presets := get_presets().filter(func(e: W4EditorPreset):
		return e.platform.begins_with("Linux")
	)
	presets.sort_custom(func (a: W4EditorPreset, b: W4EditorPreset):
		if a.is_dedicated == b.is_dedicated:
			return a.name.nocasecmp_to(b.name) <= 0
		return a.is_dedicated
	)
	return presets


static func get_web_export_presets() -> Array[W4EditorPreset]:
	var presets := get_presets().filter(func(e: W4EditorPreset):
		return e.platform == "Web"
	)
	presets.sort_custom(func (a: W4EditorPreset, b: W4EditorPreset):
		return a.name.nocasecmp_to(b.name) <= 0
	)
	return presets


static func do_export(p_w4_preset: W4EditorPreset, p_debug: bool, p_on_progress: Callable, p_on_error: Callable) -> bool:
	p_on_progress.call(0, "Preparing to export...")
	await Engine.get_main_loop().process_frame

	if ! _prepare_export_paths():
		p_on_error.call("Unable to prepare export paths")
		return false

	p_on_progress.call(25, "Exporting... This may take awhile!")
	await Engine.get_main_loop().process_frame

	# Detected desired export name from platform
	var export_name := "game"
	if p_w4_preset.platform.begins_with("Linux"):
		export_name = "game.x86_64"
	elif p_w4_preset.platform == "Web":
		export_name = "index.html"
	else:
		p_on_error.call("Unknown platform '%s'" % p_w4_preset.platform)
		return false

	# Convert from the 'res://' path to an absolute path.
	var absolute_export_path = ProjectSettings.globalize_path(EXPORT_OUTPUT_PATH + "/" + export_name)

	var args = [
		'--headless',
		'--export-debug' if p_debug else '--export-release',
		p_w4_preset.name,
		absolute_export_path,
	]

	var output = []
	var exit_code = OS.execute(OS.get_executable_path(), args, output, true)

	if exit_code != 0 or _is_dir_empty(EXPORT_OUTPUT_PATH):
		p_on_error.call("Error exporting project:", "\n".join(output))
		return false

	return true


static func do_export_zip(p_export: W4EditorPreset, p_debug: bool, p_on_progress: Callable, p_on_error: Callable) -> bool:
	if not (await do_export(p_export, p_debug, p_on_progress, p_on_error)):
		return false

	p_on_progress.call(50, "Creating zip file... This may take awhile!")
	await Engine.get_main_loop().process_frame

	var zip := ZIPPacker.new()
	if zip.open(EXPORT_ZIP_PATH) != OK:
		p_on_error.call("Unable to open ZIP file for writing")
		return false

	if not _add_dir_to_zip(zip, EXPORT_OUTPUT_PATH):
		p_on_error.call("Unable to add exported files to ZIP file")
		return false

	if zip.close() != OK:
		p_on_error.call("Unable to close ZIP file")
		return false

	return true


static func clean_export_paths() -> bool:
	if DirAccess.dir_exists_absolute(EXPORT_OUTPUT_PATH):
		if not _remove_directory(EXPORT_OUTPUT_PATH):
			return false

	if FileAccess.file_exists(EXPORT_ZIP_PATH):
		if DirAccess.remove_absolute(EXPORT_ZIP_PATH) != OK:
			return false

	return true


static func list_export_files(p_max_depth:= 1) -> Array[String]:
	return _list_files(EXPORT_OUTPUT_PATH)


static func ensure_bucket(sdk: W4Client, p_bucket: String, p_on_error: Callable, p_public:=false) -> bool:
	var result : W4Client.APIResult = await sdk.client.storage.list_buckets().async()
	if result.is_error():
		p_on_error.call("Unable to list storage buckets:", str(result))
		return false
	var found : Array = result.as_array().filter(
		func (x: Dictionary): return x.get("name", "") == p_bucket
	)
	if found.size() > 0: # and found[0].get("public", false) != p_public:
		result = await sdk.client.storage.update_bucket(p_bucket, p_public).async()
		if result.is_error():
			p_on_error.call(
				"Unable to set 'public = %s' for storage bucket '%s':" % [p_public, p_bucket],
				str(result)
			)
			return false
	elif found.is_empty():
		result = await sdk.client.storage.create_bucket(p_bucket, p_public).async()
		if result.is_error():
			p_on_error.call("Unable to create storage bucket '%s':" % p_bucket, str(result))
			return false
	return true


static func _list_files(p_path, p_max_depth:= 1) -> Array[String]:
	var out : Array[String] = []
	var dir := DirAccess.open(p_path)
	if not dir:
		return out

	dir.list_dir_begin()
	var fn = dir.get_next()
	while fn != '':
		if fn == '.' or fn == '..':
			fn = dir.get_next()
			continue
		if FileAccess.file_exists(p_path + "/" + fn):
			out.append(p_path + "/" + fn)
		elif p_max_depth > 1:
			_list_files(p_path + "/" + fn, p_max_depth - 1)
		fn = dir.get_next()
	dir.list_dir_end()
	return out


static func _prepare_export_paths() -> bool:
	if not clean_export_paths():
		return false

	if DirAccess.make_dir_recursive_absolute(EXPORT_OUTPUT_PATH) != OK:
		return false

	return true


static func _is_dir_empty(p_path: String) -> bool:
	var count := 0

	var dir := DirAccess.open(p_path)
	if not dir:
		return true

	dir.list_dir_begin()
	var fn = dir.get_next()
	while fn != '':
		if fn != '.' and fn != '..':
			count += 1
		fn = dir.get_next()
	dir.list_dir_end()

	return count == 0

static func _remove_directory(p_path: String) -> bool:
	if not DirAccess.dir_exists_absolute(p_path):
		return true

	var dir := DirAccess.open(p_path)
	if not dir:
		return false

	dir.list_dir_begin()
	var fn = dir.get_next()
	while fn != '':
		if dir.current_is_dir():
			if fn != '.' and fn != '..':
				if not _remove_directory(p_path + '/' + fn):
					return false
		else:
			if dir.remove(fn) != OK:
				return false
		fn = dir.get_next()
	dir.list_dir_end()

	if DirAccess.remove_absolute(p_path) != OK:
		return false

	return true


static func _add_dir_to_zip(p_zip: ZIPPacker, p_path: String, p_parents: Array = []) -> bool:
	var dir := DirAccess.open(p_path)
	if not dir:
		return false

	dir.list_dir_begin()
	var fn = dir.get_next()
	while fn != '':
		if dir.current_is_dir():
			if fn != '.' and fn != '..':
				if not _add_dir_to_zip(p_zip, p_path + '/' + fn, p_parents + [fn]):
					return false
		else:
			if p_zip.start_file(fn if p_parents.is_empty() else "/".join(p_parents) + "/" + fn) != OK:
				return false

			var file := FileAccess.open(p_path + "/" + fn, FileAccess.READ)
			if not file:
				return false

			while not file.eof_reached():
				var buffer = file.get_buffer(4096)
				if p_zip.write_file(buffer) != OK:
					return false

			if p_zip.close_file() != OK:
				return false

		fn = dir.get_next()
	dir.list_dir_end()

	return true
