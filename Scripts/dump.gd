extends Node

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

## from Lobby.gd
remotesync func update_player_registry(other_player_info, other_player_info_index):
	## update player dictionary
	player_info = other_player_info
	## display connection info
	for i in player_info:
		if player_info[i] != "":
			if other_player_info_index == 1:
				get_node("Panel/Player1_Connected").set_text(other_player_info[other_player_info_index] + "is hosting")
			if other_player_info_index == 2:
				$Panel/Player2_Connected.set_text(other_player_info[other_player_info_index] + "connected")
			if other_player_info_index == 3:
				$Panel/Player3_Connected.set_text(other_player_info[other_player_info_index] + "connected")
			if other_player_info_index == 4:
				$Panel/Player4_Connected.set_text(other_player_info[other_player_info_index] + "connected")
				
func display_time(minutes, seconds, msec):
	$Camera2D/Panel/Label.set_text(str(minutes) + ":" + str(seconds) + ":" + str(msec))
	$Camera2D/Panel/Label.set_text(str(minutes) + ":" + str(seconds) + ":" + str(msec))