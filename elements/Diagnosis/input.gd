extends Node2D

var FL = preload("res://elements/Diagnosis/fill_light.tscn")
var circ = preload("res://elements/Diagnosis/circle.tscn")
var tri = preload("res://elements/Diagnosis/triangle.tscn")

# Called when the node enters the scene tree for the first time.
var shown_joypads:Array = []

func _ready() -> void:
	show_joypads([])

## One full ring per connected joypad, up to the rings in the scene. Wheels get the driving marker.
func show_joypads(joypads:Array) -> void:
	if joypads == shown_joypads and !shown_joypads.is_empty():
		return
	shown_joypads = joypads
	var rings = $Controllers.get_children()
	for i in rings.size():
		rings[i].visible = i < joypads.size()
		if rings[i].visible:
			var joy_name = str(joypads[i].get("name", "")).to_lower()
			fill(rings[i], 100, "rhema_driving" if "wheel" in joy_name or "driv" in joy_name else "generic")


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
#	pass

func clear_precent(item):
	for i in item.get_node("Pivot").get_children():
		i.get_parent().remove_child(i)
		i.queue_free()

func fill(item,percentage,type):
	clear_precent(item)
	var num = 360.00 * (percentage / 100.00)
	var last_location = 0.0
	for i in range(0,num):
		var current = FL.instantiate()
		item.get_node("Pivot").add_child(current)
		var outerring_diameter = item.get_texture().get_size().x
		var r = (outerring_diameter / 2) * 0.95
		var x = 0.0
		var y = 0.0
		if current.get_index() == 0:
			x = r * cos(deg_to_rad(last_location))
			y = r * sin(deg_to_rad(last_location))
		else:
			last_location += 1
			x = r * cos(deg_to_rad(last_location))
			y = r * sin(deg_to_rad(last_location))
			
		current.position = Vector2(x,y)
		current.look_at(get_parent().pivotpoint.position)
		
		num += 1
	if type == "generic":
		var marker = circ.instantiate()
		item.get_node("Pivot").add_child(marker)
		var outerring_diameter = item.get_texture().get_size().x
		var r = (outerring_diameter / 2) * 0.95
		var x = 0.0
		var y = 0.0
		x = r * cos(deg_to_rad(num * 0.25))
		y = r * sin(deg_to_rad(num * 0.25))
		marker.position = Vector2(x+50,y+50)
		marker.scale = Vector2(0.6,0.6)
		
	if type == "rhema_driving":
		var marker = tri.instantiate()
		item.get_node("Pivot").add_child(marker)
		var outerring_diameter = item.get_texture().get_size().x
		var r = (outerring_diameter / 2) * 0.95
		var x = 0.0
		var y = 0.0
		x = r * cos(deg_to_rad(num * 0.25))
		y = r * sin(deg_to_rad(num * 0.25))
		marker.position = Vector2(x+50,y+50)
		marker.scale = Vector2(1,1)
		#marker.look_at(get_parent().pivotpoint.position)
