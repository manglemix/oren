extends State


export var chase_speed := 3.0

var target: Vector3

onready var enemy_body: Character = owner
onready var enemy_ai: Enemy = get_parent()
onready var goto: Goto = enemy_body.get_node("Goto")


func _ready():
	yield(enemy_ai, "ready")
	enemy_ai.connect("agitated", self, "_handle_agitation")
	
	if enemy_ai.player == null:
		yield(enemy_ai.current_scene, "ready")
	
	goto.connect("finished", self, "_target_reached")


func _handle_agitation(strength: float, type: int) -> void:
	match type:
		enemy_ai.AUDIO:
			if strength >= 0.01:
				enemy_ai.activate_states(self, self)
				target = enemy_ai.player.get_node("CollisionShape").global_transform.origin
		
#		enemy_ai.VISUAL:
#			if strength >= 0.1:
#				enemy_ai.activate_states(self, self)
#				target = enemy_ai.player.get_node("CollisionShape").global_transform.origin


func _target_reached() -> void:
	if active:
		enemy_ai.activate_default(self)


func _process(_delta):
	goto.goto(target)
