class_name BaseScene
extends Spatial


export var enemy_path: NodePath = "Enemy"
export var player_path: NodePath = "Player"
export var flashlight_path: NodePath = "Hand/Flashlight"
export var flash_path: NodePath = "Hand/Flash"
export var navigation_path: NodePath = "Navigation"
export var bg_music_stream: AudioStream setget set_bg_music_stream
export var bg_volume := 0.0 setget set_bg_volume
export(Array, NodePath) var debug_nodes: Array

var bg_music := AudioStreamPlayer.new()

onready var navigation: Navigation = get_node(navigation_path)
onready var enemy_body: Character = get_node(enemy_path)
onready var enemy_ai: Node = enemy_body.get_node("Enemy")
onready var player: Character = get_node(player_path)
onready var flashlight: SpotLight = get_node(flashlight_path)
onready var flash: SpotLight = get_node(flash_path)


func set_bg_music_stream(stream: AudioStream) -> void:
	bg_music_stream = stream
	bg_music.stream = stream


func set_bg_volume(db: float) -> void:
	bg_volume = db
	bg_music.volume_db = db


func play_audio_event(position: Vector3, volume := 1.0) -> void:
	enemy_ai._handle_audio_event(position, volume)


func play_visual_event(collider: CollisionObject, intensity := 1.0) -> void:
	enemy_ai._handle_visual_event(collider, intensity)


func flash_effect(linger:=0.8, fade:=2.0) -> void:
	var texture_rect := TextureRect.new()
	texture_rect.texture = ImageTexture.new()
	texture_rect.texture.create_from_image(get_viewport().get_texture().get_data())
	texture_rect.flip_v = true
	texture_rect.material = CanvasItemMaterial.new()
	texture_rect.material.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
	add_child(texture_rect)
	
	yield(get_tree().create_timer(linger), "timeout")
	var fade_effect := FadeEffect.new()
	texture_rect.add_child(fade_effect)
	fade_effect.connect("timeout", texture_rect, "queue_free")
	fade_effect.activate(fade)


func _input(event):
	if event.is_action_pressed("ui_cancel"):
		get_tree().quit()
	
	elif event.is_action_pressed("debug"):
		for path in debug_nodes:
			var node := get_node(path)
			node.visible = not node.visible


func _ready():
	bg_music.connect("finished", bg_music, "play")
	bg_music.autoplay = true
	add_child(bg_music)
