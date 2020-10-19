extends Node


enum {OMNI, TWO, THREE}


func quick_player(sound: AudioStream, dimension:=OMNI) -> Node:
	var node: Node
	
	match dimension:
		TWO:
			node = AudioStreamPlayer2D.new()
		
		THREE:
			node = AudioStreamPlayer3D.new()
		
		OMNI:
			node = AudioStreamPlayer.new()
	
	node.stream = sound
	node.autoplay = true
	node.connect("finished", node, "queue_free")
	return node
