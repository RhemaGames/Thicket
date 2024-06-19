extends Control

var navbutton = preload("res://elements/navListButton.tscn")
var Thicket

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
# Called when the node enters the scene tree for the first time.
signal activeSet(item)
# warning-ignore:unused_signal
signal activeList()
var active = false
var bgColor = Color(0.1,1,0.5)
var textColor = Color(1,1,1)
var icon = ""
var text = "Area3D"
var title = ""
var index = 1

func _ready():
	Thicket = get_node("/root/Thicket")
	index = get_index()
	$background.self_modulate = bgColor
	$underlay.self_modulate = bgColor
	$Icon.self_modulate = bgColor
	$background/area.text = text
	$background/area.self_modulate = bgColor
	$Icon.set_texture(load(icon))
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _on_underlay_mouse_exited():
	if !active:
		$AnimationPlayer.play_backwards("focus")
		
	pass # Replace with function body.


func _on_underlay_mouse_entered():
	if !active:
		$AnimationPlayer.play("focus")
		$AudioStreamPlayer2D.pitch_scale = 0.5 + (0.1 * index)
		$AudioStreamPlayer2D.play(0.0)
		Thicket.selected_color = bgColor
	pass # Replace with function body.


func _on_underlay_gui_input(_event):
	if Input.is_mouse_button_pressed(1):
		$AnimationPlayer.play("focus")
		$AudioStreamPlayer2D.pitch_scale = 0.5 + (0.1 * index)
		$AudioStreamPlayer2D.play(0.0)
		emit_signal("activeSet",text)
	pass # Replace with function body.


func _on_NavButton_activeSet(_item):
	active = true
	if !$AnimationPlayer.is_playing():
		$NavList.visible = true
		#fill_list(item)
	pass # Replace with function body.


func _on_NavButton_activeList():
	active = false
	pass # Replace with function body.
	
func _on_ActiveRelease(except):
	if text != except:
		active = false
		if $AnimationPlayer.current_animation_position != 0:
			$AnimationPlayer.play_backwards("focus")
	else:
		active = true
		#$AnimationPlayer.play("focus")
		
func fill_list(_listname):
	var musicList = [{"title":"All Music"},{"title":"All Artists"}]
	for item in musicList:
		var button = navbutton.instantiate()
		button.text = item["title"]
		$NavList.add_child(button)
	pass
	
