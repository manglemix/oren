# A simple Spatial Node which can look at another Spatial Node
class_name InterpolatedNode
extends Spatial


export var target_node_path: NodePath setget set_target_node_path
export var weight := 12.0
export var use_global_transform := true

var _is_ready := false

onready var target_node: Spatial = get_node(target_node_path) setget set_target_node


func set_target_node_path(path: NodePath) -> void:
	target_node_path = path
	
	if _is_ready:
		target_node = get_node(path)


func set_target_node(node: Spatial) -> void:
	target_node = node
	target_node_path = get_path_to(node)


func _ready():
	_is_ready = true


func _physics_process(delta):
	if use_global_transform:
		global_transform = global_transform.interpolate_with(target_node.global_transform, weight * delta)
	
	else:
		transform = transform.interpolate_with(target_node.transform, weight * delta)
