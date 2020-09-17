extends ClassicCharacter


export var movement_node_path: NodePath = "ControllableCharacterMovement"

onready var current_scene: BaseScene = get_tree().current_scene
onready var movement_node: CharacterMovement = get_node(movement_node_path)


func _process(_delta):
	if not is_zero_approx(movement_vector.length_squared()):
		if movement_node.movement_state == movement_node.FAST:
			current_scene.play_audio_event(global_transform.origin, 0.1)
		
		elif movement_node.movement_state == movement_node.DEFAULT:
			current_scene.play_audio_event(global_transform.origin, 0.01)
