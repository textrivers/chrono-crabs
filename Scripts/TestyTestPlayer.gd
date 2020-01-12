extends Node2D

var racing = false
var current_ghost = {}
var ghost_data_index = 0

func _ready():
	## get_node("/root/World/BasicDownhillTrack/FinishSystem").connect("race_finished", self, "finish_race")
	get_node("/root/ChronoCrabs/GameControl").connect("race_started", self, "start_race")
	get_node("/root/ChronoCrabs/GameControl").connect("race_finished", self, "finish_race")
	pass

func _physics_process(delta):
	reposition_camera()
	adjust_camera_offset()
	record_ghost()

func start_race():
	racing = true
	

func reposition_camera():
	$Camera2D.position = $TestPlayer.position

func adjust_camera_offset():
	$Camera2D.offset.x = lerp($Camera2D.offset.x, clamp($TestPlayer.velocity.x, 100, 300), 0.03)
	$Camera2D.offset.y = lerp($Camera2D.offset.y, clamp($TestPlayer.velocity.y, 0, 200), 0.03)

func record_ghost():
	if racing == true:
		## record ghost data: position, rotation, ?
		current_ghost[ghost_data_index] = [$TestPlayer.global_position, $TestPlayer.rotation_degrees, $TestPlayer/Sprite2.flip_h]
		ghost_data_index += 1

func finish_race(elapsed):
	print(elapsed)

	racing = false
	current_ghost["time_msec"] = elapsed

	if !game_data.ghost_data.has(game_data.track_data_index):
		## ...write ghost to game_data
		game_data.ghost_data[game_data.track_data_index] = current_ghost
		## print("ghost saved - no previous ghost")
	else:
		print("previous ghost")
	if current_ghost["time_msec"] < game_data.ghost_data[game_data.track_data_index]["time_msec"]:
		game_data.ghost_data[game_data.track_data_index] = current_ghost
		## print("ghost saved - faster than previous")
	else:
		print(str(elapsed) + " is not less than " + str(game_data.ghost_data[game_data.track_data_index]["time_msec"]))