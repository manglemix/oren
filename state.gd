class_name State
extends Node


signal activated
signal deactivated

var state_machine: StateMachine

export var active := false setget set_active
export var default := false


func set_active(value: bool) -> void:
	active = value
	set_process(active)
	set_process_input(active)
	set_physics_process(active)
	
	if active:
		emit_signal("activated")
	
	else:
		emit_signal("deactivated")


func _enter_tree():
	if get_parent() is StateMachine:
		state_machine = get_parent()
	
	elif "state_machine" in get_parent():
		state_machine = get_parent().state_machine
	
	if state_machine != null:
		state_machine.connect("default_activated", self, "handle_default")
		state_machine.connect("states_activated", self, "handle_activation")


func _exit_tree():
	if state_machine != null:
		state_machine.disconnect("default_activated", self, "handle_default")
		state_machine.disconnect("states_activated", self, "handle_activation")


func _ready():
	set_active(active)


func handle_default(emitter: Node) -> void:
	set_active(default)


func handle_activation(emitter: Node, states) -> void:
	var is_in: bool = self in states
	
	if is_in != active:
		set_active(is_in)
