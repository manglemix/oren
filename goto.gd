class_name Goto
extends KinematicBody


signal finished
signal navigation_ready

export var max_distance := 1.0
export var speed := 1.0
export var retry_time := 2.0
export var correction_step := 0.1

var _current_retry_timer: float
var navigation: Navigation
var path: PoolVector3Array setget set_path

onready var character: Character = get_parent()


func set_path(arr: PoolVector3Array) -> void:
	path = arr
	
	while path.size() > 0:
		if path[0].distance_to(character.global_transform.origin) > max_distance:
			break

		path.remove(0)
	
	set_physics_process(path.size() > 0)


func clear_path() -> void:
	set_physics_process(false)
	path = PoolVector3Array()


func end_pathfinding() -> void:
	clear_path()
	set_physics_process(false)
	character.movement_vector = Vector3.ZERO


func _ready():
	set_physics_process(false)
	
	var scene: BaseScene = get_tree().current_scene
	
	if scene.navigation == null:
		yield(scene, "ready")
	
	navigation = scene.navigation
	emit_signal("navigation_ready")


func goto(position: Vector3) -> void:
	path = navigation.get_simple_path(
		navigation.get_closest_point(navigation.to_local(character.global_transform.origin)),
		navigation.get_closest_point(navigation.to_local(position))
	)
	
	path.remove(0)
	
	for i in range(path.size()):
		path[i] = navigation.to_global(path[i])
	
	_current_retry_timer = retry_time
	set_physics_process(true)


func _physics_process(delta):
	if path[0].distance_to(character.global_transform.origin) <= max_distance:
		path.remove(0)
		
		if path.size() == 0:
			set_physics_process(false)
			character.movement_vector = Vector3.ZERO
			emit_signal("finished")
			return
	
	_current_retry_timer -= delta
	if _current_retry_timer <= 0:
		goto(path[-1])
	
	var travel := path[0] + character.global_transform.basis.xform(transform.origin) - global_transform.origin
	var result := move_and_collide(travel, true, true, true)
	
	if result:
		if path.size() > 1:
			var from_vector := character.global_transform.origin - path[0]
			var out_vector := path[1] - path[0]
			var normal_vector := (from_vector.normalized() + out_vector.normalized()) / 2
			
			if sign(character.to_local(result.position).x) == sign(character.global_transform.basis.xform_inv(normal_vector).x):
				normal_vector *= -1
			
			path[0] = navigation.to_global(
				navigation.get_closest_point(
					navigation.to_local(
						path[0] + normal_vector.normalized() * correction_step
					)
				)
			)
		
		else:
			path[0] = navigation.to_global(
				navigation.get_closest_point(
					navigation.to_local(
						path[0] + result.normal * correction_step
					)
				)
			)
	
	var debug := [character.global_transform.origin] + Array(path)
	$DrawPath.draw_global_path(debug)
	
	_look_at_point(path[0])
	character.movement_vector = character.global_transform.basis.z * - speed


func _look_at_point(point: Vector3) -> void:
	point.y = character.global_transform.origin.y
	character.look_at(point, Vector3.UP)
