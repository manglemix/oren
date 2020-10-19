extends SpotLight


export var energy_curve: Curve
export var cooldown := 3.0
export var flash_distance := 7.5

var _current_cooldown: float
var _last_energy: float

onready var current_scene: BaseScene = get_tree().current_scene


func _ready():
	visible = false
	set_process(false)


func _input(event):
	if not visible and event.is_action_pressed("flash"):
		_last_energy = light_energy
		_current_cooldown = 0
		visible = true
		set_process(true)
		current_scene.play_audio_event(current_scene.player.global_transform.origin, 0.5)
		current_scene.play_visual_event(current_scene.player, 3)
		
		if current_scene.enemy_ai.player_visible and current_scene.player.global_transform.origin.distance_to(current_scene.enemy_body.global_transform.origin) <= flash_distance:
			current_scene.enemy_ai.activate_state(self, "Run")
		
		yield(get_tree(), "idle_frame")
		yield(get_tree(), "idle_frame")
		current_scene.flash_effect()


func _process(delta):
	light_energy = energy_curve.interpolate(_current_cooldown / cooldown) * _last_energy
	_current_cooldown += delta
	
	if _current_cooldown >= cooldown:
		visible = false
		set_process(false)
		light_energy = _last_energy
