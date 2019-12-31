extends Node2D

var data
var playback = false
var data_index = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	if game_data.ghost_data.has(0):
		data = game_data.ghost_data[0]
	else:
		print("why no ghost recorded?")
	
	get_node("/root/ChronoCrabs/GameControl/StartingSystem").connect("race_started", self, "start_playback")
	get_node("/root/World/BasicDownhillTrack/FinishSystem").connect("race_finished", self, "finish_playback")

func _physics_process(delta):
	if playback == true && data.has(data_index):
		position = data[data_index][0]
		rotation_degrees = data[data_index][1]
		data_index += 1
	else:
		if data_index > 1:
			finish_playback()
		
	
func start_playback():
	playback = true

func finish_playback():
	playback = false
	$Sprite.hide()