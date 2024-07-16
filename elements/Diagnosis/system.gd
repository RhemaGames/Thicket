extends Node2D

var str_prct = 1
var mem_prct = 1
var FL = preload("res://elements/Diagnosis/fill_light.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	fill($Storage,str_prct)
	fill($Memory,str_prct)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
#	pass

func clear_precent(item):
	for i in item.get_node("Pivot").get_children():
		i.get_parent().remove_child(i)
		i.queue_free()

func fill(item,percentage):
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
	


func _on_timer_timeout() -> void:
	if str_prct <= 99:
		str_prct += 1
	else:
		str_prct = 1
	
	if mem_prct <= 99:
		mem_prct += 3
	else:
		mem_prct = 3
	
	fill($Memory,mem_prct)
	fill($Storage,str_prct)
	
