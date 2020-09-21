class_name Goto
extends KinematicBody


signal finished
signal navigation_ready

export var max_distance := 1.0
export var minor_distance := 0.1
export var speed := 1.0
export var retry_time := 2.0
export var face_path := true

var _current_retry_timer: float
var navigation: Navigation
var path: PoolVector3Array setget set_path

var _sliding := false

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
	
	var tmp_array: PoolVector3Array
	var last_point := navigation.to_global(path[0])
	tmp_array.append(last_point)
	
	for i in range(1, path.size()):
		var tmp_point := navigation.to_global(path[i])
		
		if not last_point.is_equal_approx(tmp_point):
			tmp_array.append(tmp_point)
		
		last_point = tmp_point
	
	path = tmp_array
	_current_retry_timer = retry_time
	set_physics_process(true)


func _physics_process(delta):
	if path.size() == 0:
		set_physics_process(false)
		character.movement_vector = Vector3.ZERO
		emit_signal("finished")
		return
	
	_current_retry_timer -= delta
	if _current_retry_timer <= 0:
		goto(path[-1])
	
	if path.size() > 1:
		if path[0].distance_to(character.global_transform.origin) <= minor_distance:
			path.remove(0)
			
			if path.size() == 1:
				return
		
		var in_vector := (path[0] - character.global_transform.origin).normalized()
		var out_vector := (path[1] - path[0]).normalized()
		
		if in_vector.dot(out_vector) >= 0.95:
			path.remove(0)
	
	elif path[0].distance_to(character.global_transform.origin) <= max_distance:
		path.remove(0)
		return
	
	var relative_path := path[0] - character.global_transform.origin
	var result := _test_move_to_point(path[0] + character.global_transform.basis.xform(transform.origin) - global_transform.origin)
	
	if result and result.travel.length() <= minor_distance:
		if path.size() == 1 or not _sliding:
			character.movement_vector = relative_path.slide(result.normal).normalized() * speed
			_sliding = true
	
	else:
		character.movement_vector = relative_path.normalized() * speed
		_sliding = false
	
	if face_path and not is_zero_approx(character.movement_vector.length_squared()):
		_look_at_point(character.global_transform.origin + character.movement_vector)
	
	var debug := [character.global_transform.origin] + Array(path)
	$DrawPath.draw_global_path(debug)


func _look_at_point(point: Vector3) -> void:
	point.y = character.global_transform.origin.y
	character.look_at(point, Vector3.UP)


func _test_move_to_point(point: Vector3) -> KinematicCollision:
	return move_and_collide(point, true, true, true)
