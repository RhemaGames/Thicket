extends RefCounted

class SafeTimer extends RefCounted:

	signal timeout()

	var wait_time : float :
		set(time):
			_set_time(time)
		get:
			return _time * 1000.0

	var _start := 0
	var _time := 0
	var _repeat := false
	var _stopped := true

	func _init(time: float, repeat: bool, autostart: bool):
		_repeat = repeat
		_start = Time.get_ticks_msec()
		_set_time(time)
		if _time > 0 and autostart:
			_stopped = false
		Engine.get_main_loop().process_frame.connect(_tick)


	func _set_time(time: float):
		_time = maxi(0, roundi(time * 1000))


	func _tick():
		if _stopped:
			return
		if _start + _time > Time.get_ticks_msec():
			return
		if _repeat:
			_start = Time.get_ticks_msec()
		else:
			_stopped = true
		timeout.emit()


	func connected_to(callable: Callable) -> SafeTimer:
		timeout.connect(callable)
		return self


	func start(time:=0.0):
		_start = Time.get_ticks_msec()
		if time != 0.0:
			_set_time(time)
		assert(_time > 0)
		_stopped = false


	func stop():
		_stopped = true


	func stop_notify():
		if _stopped:
			return
		stop()
		timeout.emit()


static func create_timeout(time:=0.0, autostart:=true) -> SafeTimer:
	return SafeTimer.new(time, false, autostart)


static func create_interval(time:=0.0, autostart:=true) -> SafeTimer:
	return SafeTimer.new(time, true, autostart)
