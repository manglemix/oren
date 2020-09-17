class_name Enemy
extends StateMachine


enum {VISUAL, AUDIO}

signal agitated(strength, type)

export var audio_sensitivity := 10.0
export var visual_sensitivity := 10.0
export var minimum_player_intensity := 1.0
export var player_cast_target_path := "CollisionShape"
export var cast_origin_path: NodePath = "../CollisionShape"

var player: Character
var player_cast_target: Spatial
var flashlight: SpotLight
var direct_space_state: PhysicsDirectSpaceState

onready var parent: Character = get_parent()
onready var current_scene: BaseScene = get_tree().current_scene
onready var cast_origin: Spatial = get_node(cast_origin_path)


func _enter_tree():
	if parent == null:
		yield(self, "ready")
	
	direct_space_state = parent.get_world().direct_space_state


func _ready():
	if current_scene.player == null or current_scene.flashlight == null:
		yield(current_scene, "ready")
	
	player = current_scene.player
	flashlight = current_scene.flashlight
	player_cast_target = player.get_node(player_cast_target_path)


func _handle_audio_event(position: Vector3, volume := 1.0) -> void:
	emit_signal("agitated", volume / (position - parent.global_transform.origin).length_squared() * audio_sensitivity, AUDIO)


func _handle_visual_event(collider: CollisionObject, intensity := 1.0) -> void:
	var result := direct_space_state.intersect_ray(cast_origin.global_transform.origin, collider.global_transform.origin)
	
	if not result.empty():
		if result["collider"] == collider:
			emit_signal("agitated", intensity * visual_sensitivity / (cast_origin.global_transform.origin - result["position"]).length_squared(), VISUAL)


func _physics_process(_delta):
	_handle_visual_event(player, flashlight.light_energy * float(flashlight.visible) + minimum_player_intensity)
