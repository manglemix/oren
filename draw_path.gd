class_name DrawPath
extends ImmediateGeometry


func draw_local_path(path: Array) -> void:
	clear()
	begin(Mesh.PRIMITIVE_LINE_STRIP, null)
	
	for x in path:
		add_vertex(x)
	
	end()


func draw_global_path(path: Array) -> void:
	clear()
	begin(Mesh.PRIMITIVE_LINE_STRIP, null)
	
	for x in path:
		add_vertex(to_local(x))
	
	end()


func draw_local_vector(vector: Vector3, origin: Vector3) -> void:
	clear()
	begin(Mesh.PRIMITIVE_LINE_STRIP, null)
	add_vertex(origin)
	add_vertex(origin + vector)
	end()


func draw_global_vector(vector: Vector3, origin: Vector3) -> void:
	draw_local_vector(global_transform.basis.xform_inv(vector), to_local(origin))
