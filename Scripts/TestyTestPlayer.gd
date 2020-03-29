extends Node2D

var racing = false
var current_ghost = {}
var ghost_data_index = 0

var current_shell
var current_shell_sprite

var track


func _ready():
	## get_node("/root/World/BasicDownhillTrack/FinishSystem").connect("race_finished", self, "finish_race")
# warning-ignore:return_value_discarded
	get_node("/root/ChronoCrabs/GameControl").connect("race_started", self, "start_race")
# warning-ignore:return_value_discarded
	get_node("/root/ChronoCrabs/GameControl").connect("race_finished", self, "finish_race")
	current_shell = $TestPlayer
	current_shell_sprite = $TestPlayer/ShellSprite
	track = get_node("..")

# warning-ignore:unused_argument
func _physics_process(delta):
	reposition_camera()
	adjust_camera_offset()
	record_ghost()

func start_race():
	racing = true

func reposition_camera():
	$Camera2D.position = current_shell.position

func adjust_camera_offset():
	$Camera2D.offset.x = lerp($Camera2D.offset.x, clamp(current_shell.velocity.x, 100, 300), 0.03)
	$Camera2D.offset.y = lerp($Camera2D.offset.y, clamp(current_shell.velocity.y, 0, 200), 0.03)

func record_ghost():
	if racing == true:
		## record ghost data: position, rotation, ?
		current_ghost[ghost_data_index] = [current_shell.global_position, current_shell.rotation_degrees, current_shell_sprite.flip_h]
		ghost_data_index += 1

func swap_shells(new_shell):
	## current_shell.racing = true
	current_shell.can_swap = false
	current_shell.occupied = false
	get_node(str(get_path_to(current_shell)) + "/ShellSprite/CrabSprite").hide()
	get_node(str(get_path_to(current_shell)) + "/Area2D/CollisionShape2D").disabled = false
	var glob_pos = current_shell.global_position
	remove_child(current_shell)
	track.add_child(current_shell)
	current_shell.global_position = glob_pos
	current_shell = new_shell
	current_shell_sprite = get_node(str(get_path_to(new_shell)) + "/ShellSprite")

func finish_race(elapsed):
	print(elapsed)

	racing = false
	current_ghost["time_msec"] = elapsed

	if !game_data.ghost_data.has(game_data.track_data_index):
		## ...write ghost to game_data
		game_data.ghost_data[game_data.track_data_index] = current_ghost
	
	if current_ghost["time_msec"] < game_data.ghost_data[game_data.track_data_index]["time_msec"]:
		game_data.ghost_data[game_data.track_data_index] = current_ghost
		## print("ghost saved - faster than previous")
	
