extends State


export var speed := 5.0
export var max_dimension_length := 30.0

var _last_position: Vector3

onready var enemy_body: Character = owner
onready var enemy_ai: Enemy = get_parent()
onready var goto: Goto = enemy_body.get_node("Goto")


func running() -> void:
	enemy_ai.sensing = false
	_last_position = get_tree().current_scene.player.global_transform.origin
	goto.speed = speed
	goto.goto(enemy_body.global_transform.origin + Vector3(
			rand_range(- max_dimension_length, max_dimension_length),
			rand_range(- max_dimension_length, max_dimension_length),
			rand_range(- max_dimension_length, max_dimension_length)
		)
	)
	
	yield(goto, "finished")
	enemy_ai.sensing = true
	goto.goto(_last_position)
	yield(goto, "finished")
	
	if active:
		enemy_ai.activate_default(self)


func _ready():
	connect("activated", self, "running")
