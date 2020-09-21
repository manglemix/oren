class_name State
extends Node


signal activated
signal deactivated

export var active := false setget set_active
export var default := false

var state_machine: StateMachine


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
		state_machine.connect("state_activated", self, "handle_activation")


func _exit_tree():
	if state_machine != null:
		state_machine.disconnect("default_activated", self, "handle_default")
		state_machine.disconnect("state_activated", self, "handle_activation")


func _ready():
	set_active(active)


func handle_default(emitter: Node) -> void:
	set_active(default)


func handle_activation(emitter: Node, state) -> void:
	if (self == state) != active:
		set_active(not active)
