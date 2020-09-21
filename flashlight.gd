class_name Flashlight
extends SpotLight


func _input(event):
	if event.is_action_pressed("flashlight"):
		visible = not visible
