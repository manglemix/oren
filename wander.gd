extends State


export var speed := 2.0
export var max_dimension_length := 10.0

onready var enemy_body: Character = owner
onready var enemy_ai: Enemy = get_parent()
onready var goto: Goto = enemy_body.get_node("Goto")


func random_path() -> void:
	if active:
		goto.speed = speed
		goto.goto(enemy_body.global_transform.origin + Vector3(
				rand_range(- max_dimension_length, max_dimension_length),
				rand_range(- max_dimension_length, max_dimension_length),
				rand_range(- max_dimension_length, max_dimension_length)
			)
		)


func _ready():
	yield(enemy_ai, "ready")
	connect("activated", self, "random_path")
	goto.connect("finished", self, "random_path")
	connect("deactivated", goto, "clear_path")
	
	if goto.navigation == null:
		yield(goto, "navigation_ready")
	
	if active:
		random_path()
