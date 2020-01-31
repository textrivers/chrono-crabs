extends Node2D

var data
var playback = false
var frame_index = 0

var start_pos = Vector2(0, 0)

# Called when the node enters the scene tree for the first time.
func _ready():
	
# warning-ignore:return_value_discarded
	get_node("/root/ChronoCrabs/GameControl").connect("race_started", self, "start_playback")
# warning-ignore:return_value_discarded
	get_node("/root/ChronoCrabs/GameControl").connect("race_finished", self, "finish_playback")
	data = game_data.ghost_data[game_data.track_data_index]
	
	randomize()
	position.x = -((randi() % 100) + 300)
	position.y = -((randi() % 100) + 800)

# warning-ignore:unused_argument
func _physics_process(delta):
	if frame_index == 0:
		position = lerp(position, data[1][0], 0.03)
	if playback == true && data.has(frame_index):
		position = data[frame_index][0]
		rotation_degrees = data[frame_index][1]
		if data[frame_index][2] == true:
			$Particles2D.scale.x = -1
		else:
			$Particles2D.scale.x = 1
		frame_index += 1
	else:
		if frame_index > 1:
			finish_playback()
	
func start_playback():
	playback = true

func finish_playback():
	playback = false
	$Sprite.hide()
	$Particles2D.hide()