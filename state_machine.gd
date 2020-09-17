class_name StateMachine
extends Node


signal default_activated(emitter)
signal states_activated(emitter, states)


func activate_default(emitter: Node) -> void:
	emit_signal("default_activated", emitter)


func activate_states(emitter: Node, states) -> void:
	if states is Array:
		emit_signal("states_activated", emitter, states)
	
	elif states is Node:
		emit_signal("states_activated", emitter, [states])
	
	else:
		push_error("states is not an Array of Nodes, or a Node")
