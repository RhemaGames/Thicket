## A promise which can have a chain of callbacks that can be resolved asynchronously or blocking.
##
## Calling [method async] or [method blocking] will start resolving the promise asynchronously or blocking, respectively.
##
## All of the callbacks added via [method then] will be called with the result.
extends RefCounted

## The promise status.
enum Status {PENDING, COMPLETED, FAILED}

## The chain of callbacks.
var chain : Array[Callable]
## The result of the REST request.
var result
## The promise status.
var status := Status.PENDING

var _run_async : Callable
var _run_blocking : Callable
var _results : Array
var _cancelled := false

## Emitted when the entire promise chain has completed or failed.
signal completed()

func _init(run_async: Callable, run_blocking:=Callable()):
	_run_async = run_async
	_run_blocking = run_blocking


func _w4_client_promise():
	pass


func _fail():
	status = Status.FAILED


## Starts an asynchronous HTTP request to fulfill the promise.
func async():
	assert(status == Status.PENDING)
	assert(_run_async.is_valid())
	# Hang on to all results so they don't go out of scope, leading to endless await.
	# @todo This is most likely a "bug" - hopefully it'll get fixed eventually!
	_results = []
	result = await _run_async.call(_fail)
	_results.append(result)
	for c in chain:
		result = await c.call(result)
		while is_promise(result):
			if _cancelled:
				result.cancel()
			result = await result.async()
			_results.append(result)
	if status != Status.FAILED:
		status = Status.COMPLETED
	completed.emit()
	return result


## Starts a blocking HTTP request to fulfill the promise.
func blocking(poll_delay_usec:=1000):
	assert(status == Status.PENDING)
	assert(_run_blocking.is_valid())
	result = _run_blocking.call(poll_delay_usec, _fail)
	for c in chain:
		result = c.call(result)
		while is_promise(result):
			if _cancelled:
				result.cancel()
			result = result.blocking(poll_delay_usec)
	if status != Status.FAILED:
		status = Status.COMPLETED
	completed.emit()
	return result


func then(callable: Callable):
	chain.push_back(callable)
	return self


func cancel():
	if status == Status.COMPLETED or _cancelled:
		return
	_fail()
	_cancelled = true
	# Try to cancel any pending child promise
	if result is Object and result.has_method("_w4_client_promise"):
		result.cancel()


static func _make_promise(callable: Callable):
	return new(func (_1): return callable.call(), func(_1, _2): return callable.call())


## Creates a new promise that will resolve the given array of promises in sequence.
static func sequence(promises: Array):
	if promises.any(func(e): return not e is Callable and not e.has_method("_w4_client_promise")):
		push_error("The input must be an array of promises")
		return null
	var run_async = func (fail):
		var results = []
		for p in promises:
			if p is Callable:
				p = _make_promise(p)
			results.append(await p.async())
			if p.status == Status.FAILED:
				break
		return results
	var run_blocking = func (poll_delay_usec, reject):
		var results = []
		for p in promises:
			if p is Callable:
				p = _make_promise(p)
			results.append(p.blocking(poll_delay_usec))
			if p.status == Status.FAILED:
				break
		return results
	return new(run_async, run_blocking)


## Creates a new promise that will resolve the given array of promises in parallel.
static func parallel(promises: Array):
	if promises.any(func(e): return not e is Callable and not is_promise(e)):
		push_error("The input must be an array of promises")
		return null
	var run_async = func (fail):
		var size = promises.size()
		if size == 0:
			return []
		var results := []
		results.resize(size)
		var state := {
			left = size,
		}
		var inner := new(Callable(), Callable())
		var advance := func(promise, idx):
			results[idx] = promise.result
			state.left -= 1
			if state.left == 0:
				inner.completed.emit()
		var idx := 0
		for p in promises:
			if p is Callable:
				p = _make_promise(p)
			p.completed.connect(advance.bind(p, idx), CONNECT_ONE_SHOT)
			idx += 1
			p.async()
		await inner.completed
		return results
	var run_blocking = func (poll_delay_usec, reject):
		push_error("Parallel 'blocking' is not yet supported")
		return null
	return new(run_async, run_blocking)


static func is_promise(obj) -> bool:
	return obj is Object and obj.has_method("_w4_client_promise")
