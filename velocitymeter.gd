class_name VelocityMeter
extends DrawPath


var _last_origin: Vector3
var _velocity: Vector3

onready var target: Spatial = get_parent()


func _process(delta):
	_velocity = (target.global_transform.origin - _last_origin) / delta
	_last_origin = target.global_transform.origin
	draw_global_path([target.global_transform.origin, target.global_transform.origin + _velocity])
