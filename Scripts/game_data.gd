extends Node

var player_info = {
	0: 1
}

var track_data_index = 0
var track_data = {
	0: "res://Scenes/BasicDownhillTrack.tscn",
	1: "res://Scenes/TrackRollerCoaster.tscn"
}

var playing_with_ghost = false
var ghost_data = {}



# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
