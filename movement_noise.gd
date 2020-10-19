class_name MovementNoise
extends Node


export var max_speed := 5.0
export var min_speed := 0.0
export var volume := 0.0
export var max_volume := - 5.0
export(Array, AudioStreamSample) var sounds: Array

var audio_player: AudioStreamPlayer3D

onready var parent: Character = get_parent()


func _process(delta):
	var speed := parent.linear_velocity.length()
	
	if speed > max_speed or speed < min_speed:
		if is_instance_valid(audio_player):
			audio_player.stop()
	
	elif not is_instance_valid(audio_player):
		audio_player = AudioQueue.quick_player(sounds[int(rand_range(0, sounds.size()))], AudioQueue.THREE)
		audio_player.attenuation_model = AudioStreamPlayer3D.ATTENUATION_INVERSE_SQUARE_DISTANCE
		audio_player.unit_db = volume
		audio_player.max_db = max_volume
		parent.add_child(audio_player)
