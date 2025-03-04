extends RefCounted

const Client = preload("client.gd")
const Identity = preload("identity.gd")
const Realtime = preload("realtime.gd")


## Emited when the watched table rows change. Get the row(s) values with get_records() or
## get_record() (when using watch_by_id(...))
signal updated()

# The watched table.
var _table := ""
var _id_column := ""
var _timestamp_column := ""
var _filter := ""

# Actual records state.
var _records = {}

var _snapshot_ready := false
var _snapshot_timestamp := 0
var _buffered_events := []

# Supabase.
var _client: Client
var _channel: Realtime.Subscription = null

func _init(p_client: Client):
	_client = p_client

## Watch the given table for changes.
##
## [param p_table] will refer to a table on the 'public' schema, unless give a fully qualified table name (ex. 'schema.table_name').
##
## [param p_id_column] the table's column used as an ID (should be non-nullable and unique)
##
## [param p_timestamp_column] the table's column used as a "last update" timestamp. This is needed to make sure outdated data is discarded.
##
## [param p_filter] is a special string specifying the column, operator and value to filter on. For example, `'body=eq.hey'` will
## filter for rows where the 'body' column equals 'hey'. For more information, see the Supabase docs:
## https://supabase.com/docs/guides/realtime/postgres-changes#filter-changes
func watch(p_table: String, p_id_column: String, p_timestamp_column: String, p_filter: String = ""):
	# Subscribe to the channel
	unwatch()
	_channel = _client.realtime.channel(p_table + "_" + p_filter + "_watcher")
	_channel.on_postgres_changes('*', p_table, p_filter)
	_channel.subscribed.connect(self._fetch)
	_channel.inserted.connect(self._new_event)
	_channel.updated.connect(self._new_event)
	_channel.deleted.connect(self._new_event)

	_table = p_table
	_id_column = p_id_column
	_timestamp_column = p_timestamp_column
	_filter = p_filter

	_snapshot_ready = false
	await _channel.subscribe()


## Watch the given table for change to a row with a given ID.
##
## [param p_table] will refer to a table on the 'public' schema, unless give a fully qualified table name (ex. 'schema.table_name').
##
## [param p_id_column] the table's column used as an ID (should be non-nullable and unique)
##
## [param p_timestamp_column] the table's column used as a "last update" timestamp. This is needed to make sure outdated data is discarded.
##
## [param p_id] the ID of the table row to watch for change.
func watch_by_id(p_table: String, p_id_column: String, p_timestamp_column: String, p_id: String):
	var filter = "%s=eq.%s" % [p_id_column, p_id]
	watch(p_table, p_id_column, p_timestamp_column, filter)


## Stop watching changes and reset the records.
func unwatch():
	if _channel != null:
		_channel.unsubscribe()
		_channel = null
	_records = {}


## Returns all records as a dictionary, where the key is the ID of each record.
func get_records():
	return _records


## A helper to use with watch_by_id. Returns the watched record if it exists, or null otherwise.
func get_record():
	assert(_records.size() <= 1, "Cannot use get_record() while watching multiple rows. Use watch_by_id(...) instead of watch(...)")
	if _records.size() == 1:
		var id = _records.keys()[0]
		return _records[id]
	return null


func _new_event(p_data):
	if _snapshot_ready:
		_process_event(p_data, true)
	else:
		_buffered_events.push_back(p_data)


## Fetch the data, updating the cache accordingly.
func _fetch():
	var schema: String
	var table: String

	var table_parts = _table.split('.')
	if table_parts.size() == 1:
		schema = 'public'
		table = _table
	else:
		schema = table_parts[0]
		table = table_parts[1]

	var path = "/%s" % [table]
	var query = {}
	if _filter != "":
		var arr = _filter.split("=")
		assert(arr.size() == 2, 'Filter format is invalid, expected \"<column>=<operator>.<value>\". Got %s' % [_filter])
		query[arr[0]] = arr[1]
	var extra_headers = {
		"Accept-Profile": schema
	}
	var result = await _client.rest.GET(path, query, extra_headers).async()
	if result.is_error():
		print ("Error fetching data: ", result)
		return
	_process_snapshot(result.as_array())


func _process_snapshot(p_records: Array):
	_snapshot_timestamp = 0
	_records = {}
	for record in p_records:
		var record_timestamp = record[_timestamp_column]
		if record_timestamp is String:
			record_timestamp = Time.get_unix_time_from_datetime_string(record_timestamp)
		_snapshot_timestamp = max(_snapshot_timestamp, record_timestamp)
		_records[record[_id_column]] = record
	for event in _buffered_events:
		_process_event(event, false)
	_buffered_events = []
	_snapshot_ready = true
	updated.emit()


func _process_event(p_event: Dictionary, p_emit: bool ):
	var timestamp = Time.get_unix_time_from_datetime_string(p_event["commit_timestamp"])
	if timestamp < _snapshot_timestamp:
		return

	var type = p_event["type"]
	var record
	if type == "INSERT" or type == "UPDATE":
		record = p_event["record"]
	elif type == "DELETE":
		record = p_event["old_record"]
	else:
		assert(false)
	var record_id = record[_id_column]

	if type == "INSERT" or type == "UPDATE":
		_records[record_id] = p_event.record
	elif type == "DELETE":
		_records.erase(record_id)
	else:
		assert(false)
	if p_emit:
		updated.emit()
