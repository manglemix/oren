class_name BaseScene
extends Spatial


export var enemy_path: NodePath = "Enemy"
export var player_path: NodePath = "Player"
export var flashlight_path: NodePath = "Hand/SpotLight"
export var navigation_path: NodePath = "Navigation"

onready var navigation: Navigation = get_node(navigation_path)
onready var enemy_body: Character = get_node(enemy_path)
onready var enemy_ai: Node = enemy_body.get_node("Enemy")
onready var player: Character = get_node(player_path)
onready var flashlight: SpotLight = get_node(flashlight_path)


func play_audio_event(position: Vector3, volume := 1.0) -> void:
	enemy_ai._handle_audio_event(position, volume)


func _input(event):
	if event.is_action_pressed("flashlight"):
		flashlight.visible = not flashlight.visible
	
	elif event.is_action_pressed("ui_cancel"):
		get_tree().quit()
