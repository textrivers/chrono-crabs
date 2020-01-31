extends Node

# warning-ignore:unused_class_variable
var player_info = {
	0: 1
}

# warning-ignore:unused_class_variable
var track_data_index = 0
# warning-ignore:unused_class_variable
var track_data = {
	0: "res://Scenes/ProperDunesTrack.tscn",
	1: "res://Scenes/RepetitiveDunesTrack.tscn", 
	2: "res://Scenes/SkiJumpDunesTrack.tscn"
}

# warning-ignore:unused_class_variable
var playing_with_ghost = false
# warning-ignore:unused_class_variable
var ghost_data = {}



# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
