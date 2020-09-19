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
var direct_space_state: PhysicsDirectSpaceState

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


func _enter_tree():
	direct_space_state = get_world().direct_space_state


func _ready():
	set_physics_process(false)
	
	var scene: BaseScene = get_tree().current_scene
	
	if scene.navigation == null:
		yield(scene, "ready")
	
	navigation = scene.navigation
	emit_signal("navigation_ready")


func solve_path(destination: Vector3, origin:=global_transform.origin) -> PoolVector3Array:
	return navigation.get_simple_path(
		navigation.get_closest_point(navigation.to_local(origin)),
		navigation.get_closest_point(navigation.to_local(destination))
	)


func path_length(arr: PoolVector3Array) -> float:
	var last := arr[0]
	var length: float
	
	for i in range(1, arr.size()):
		length += last.distance_to(arr[i])
		last = arr[i]
	
	return length


func goto(position: Vector3) -> void:
	path = solve_path(position)
	
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
	
	var result := _test_move_to_point(path[0])
	
	if result:
		if path.size() > 1:
			var from_vector := (character.global_transform.origin - path[0]).normalized()
			var out_vector := (path[1] - path[0]).normalized()
			var normal_vector := from_vector.linear_interpolate(out_vector, 0.5)
			
			if normal_vector.angle_to(from_vector) <= PI / 4:
				normal_vector = from_vector
				
			elif sign(character.global_transform.basis.xform_inv(result.normal).x) != sign(character.global_transform.basis.xform_inv(normal_vector).x):
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


func _test_move_to_point(point: Vector3) -> KinematicCollision:
	return move_and_collide(point + character.global_transform.basis.xform(transform.origin) - global_transform.origin, true, true, true)
