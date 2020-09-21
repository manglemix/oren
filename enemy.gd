class_name Enemy
extends StateMachine


enum {VISUAL, AUDIO}

signal agitated(strength, type)

export var audio_sensitivity := 10.0
export var visual_sensitivity := 10.0
export var flashlight_visibility := 1.5
export var player_speed_factor := 0.1
export var minimum_player_visibility := 0.1
export var player_cast_target_path := "CollisionShape"
export var cast_origin_path: NodePath = "../CollisionShape"

var navigation: Navigation
var player: Character
var player_visible: bool
var player_cast_target: Spatial
var flashlight: SpotLight
var flash: SpotLight
var direct_space_state: PhysicsDirectSpaceState
var sensing := true

onready var parent: Character = get_parent()
onready var goto: Goto = parent.get_node("Goto")
onready var current_scene: BaseScene = get_tree().current_scene
onready var cast_origin: Spatial = get_node(cast_origin_path)


func _enter_tree():
	if parent == null:
		yield(self, "ready")
	
	direct_space_state = parent.get_world().direct_space_state


func _ready():
	set_physics_process(false)
	
	if current_scene.player == null or current_scene.flashlight == null or current_scene.flash == null:
		yield(current_scene, "ready")
	
	player = current_scene.player
	flashlight = current_scene.flashlight
	flash = current_scene.flash
	player_cast_target = player.get_node(player_cast_target_path)
	set_physics_process(true)


func _handle_audio_event(position: Vector3, volume := 1.0) -> void:
	if not sensing:
		return
	
	if goto == null:
		yield(self, "ready")
	
	emit_signal("agitated", volume / pow(goto.path_length(goto.solve_path(position)), 2) * audio_sensitivity, AUDIO)


func _handle_visual_event(collider: Spatial, intensity := 1.0) -> bool:
	if not sensing:
		return false
	
	var result := direct_space_state.intersect_ray(cast_origin.global_transform.origin, collider.global_transform.origin)
	
	if not result.empty():
		if result["collider"] == collider or result["collider"] == collider.owner:
			emit_signal("agitated", intensity * visual_sensitivity / (cast_origin.global_transform.origin - result["position"]).length_squared(), VISUAL)
			return true
	
	return false


func _physics_process(_delta):
	player_visible = _handle_visual_event(player_cast_target, flashlight.light_energy * flashlight_visibility * float(flashlight.visible) + player.linear_velocity.length() * player_speed_factor + minimum_player_visibility)
