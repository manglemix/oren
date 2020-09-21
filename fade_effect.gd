class_name FadeEffect
extends Node


signal timeout

var current_time: float
var parent: CanvasItem

var _alpha_step: float


func _enter_tree():
	parent = get_parent()


func _ready():
	set_process(false)


func activate(duration:=1.0) -> void:
	current_time = duration
	_alpha_step = parent.modulate.a / duration
	set_process(true)


func _process(delta):
	current_time -= delta
	parent.modulate.a -= _alpha_step * delta
	
	if current_time <= 0:
		emit_signal("timeout")
		set_process(false)
