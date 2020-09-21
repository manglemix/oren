class_name StateMachine
extends Node


signal default_activated(emitter)
signal state_activated(emitter, states)


func activate_default(emitter: Node) -> void:
	emit_signal("default_activated", emitter)


func activate_state(emitter: Node, state) -> void:
	if state is Node:
		emit_signal("state_activated", emitter, state)
	
	elif state is String or state is NodePath:
		emit_signal("state_activated", emitter, get_node(state))
	
	else:
		push_error("states is not a Node, NodePath, or String")
