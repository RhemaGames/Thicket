## A promise that is resolved by making an HTTP request.
extends "client_promise.gd"

const Result = preload("client_result.gd")
const AsyncResult = preload("client_async_result.gd")
const BlockingResult = preload("client_blocking_result.gd")
const SafeTimer = preload("../timers/safe_timer.gd")

## The [TLSOptions] for the HTTP request.
var tls_options : TLSOptions = null
## The request method.
var request_method : int = HTTPClient.METHOD_GET
## The request headers.
var request_headers : PackedStringArray
## The request body.
var request_body : PackedByteArray
## The request URL.
var request_url : String
## The request path.
var request_path : String
## The retry timer.
var retry_timer := SafeTimer.create_timeout()
## The current retry count.
var retry_count := 0
## The retry backoff intervals.
var retry_backoffs : Array[float] = []
## A node in the scene tree that we can add an [HTTPRequest] to.
var node : Node

## Emitted when a request is being retried.
signal retrying()

#region Reference lifecycle
static func _track_ref(node: Node, ref: RefCounted):
	# Make sure the result surives the duration of the request if the user
	# is not keeping a reference to it.
	var id := ref.get_instance_id()
	var keep := ("_keep_%d" % id).replace("-", "N")
	node.set_meta(keep, ref)
	ref.completed.connect(_untrack_ref.bind(node, id), CONNECT_DEFERRED | CONNECT_ONE_SHOT)

static func _untrack_ref(node: Node, id: int):
	if not is_instance_valid(node) or node.is_queued_for_deletion():
		return
	var keep := ("_keep_%d" % id).replace("-", "N")
	node.remove_meta(keep)
#endregion


func _init():
	_run_async = request_async
	_run_blocking = request_blocking


func async():
	# We need to keep track of async requests to make sure they don't go out of
	# scope if the user code don't await, nor keep a reference.
	# FIXME A much better approach would be doing this in client_promise.gd
	# using a static variable. That approach works during runtime, but causes
	# crashes when used from the editor (possibly due to script reloading).
	# TODO Make an MRP and report the above upstream.
	_track_ref(node, self)
	return await super.async()


## Callback used to execute a blocking HTTP request.
func request_blocking(poll_delay_usec, fail: Callable):
	assert(result == null)
	result = BlockingResult.new()
	if request_url.is_empty() or status == Status.FAILED:
		result.result_status = Result.ResultStatus.ERROR
		result.http_request_result = HTTPRequest.RESULT_CANT_CONNECT
		fail.call()
		return result
	result.poll_delay_usec = poll_delay_usec
	var err = result.connect_to_url(request_url, tls_options)
	if err != OK:
		return result
	result.make_request(request_path, request_headers, request_method, request_body)
	if result.is_http_error():
		fail.call()
	return result


## Callback used to execute an asynchronous HTTP request.
func request_async(fail: Callable):
	assert(result == null)
	var req = HTTPRequest.new()
	req.max_redirects = 0
	if tls_options != null:
		req.set_tls_options(tls_options)
	if OS.get_name() != "Web":
		req.use_threads = true
	self.node.add_child(req)
	if status == Status.FAILED or request_url.is_empty() or req.request_raw(
			request_url + request_path,
			request_headers,
			request_method,
			request_body
		) != OK:
		req.queue_free()
		req = null

	# The result object will always call "completed" deferred, even if the
	# HTTPRqeust is null (after setting the appropriate error status).
	result = AsyncResult.new(req)

	await result.completed

	if not result.is_error() or status == Status.FAILED:
		return result

	# Retry
	var can_retry : bool = result.is_network_error() or result.is_http_server_error()
	if can_retry and retry_count < retry_backoffs.size() and node.is_inside_tree():
		retry_timer.start(retry_backoffs[retry_count])
		retry_count += 1
		await retry_timer.timeout
		if status == Status.FAILED:
			return result # Cancelled
		retrying.emit()
		# Keep reference, or we might end up with the same issue described in
		# "ClientPromise.async".
		_results.append(result)
		result = null
		return await request_async(fail)

	# Can't retry, or retry limit reached.
	fail.call()
	return result


func cancel():
	if status == Status.COMPLETED or _cancelled:
		return
	super.cancel()
	if result is AsyncResult or result is BlockingResult:
		result.cancel()
	# Force resuming any paused retry.
	retry_timer.stop_notify()
