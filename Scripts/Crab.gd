extends Node2D

var racing = false
var current_ghost = {}
var ghost_data_index = 0

var current_shell

var swap_target
var ready_to_swap = false
var swapping = false
var current_container
var new_container
var world
var swap_velocity = Vector2()

var withdrawn = false

const ANIM_WALK_CONST = 0.015
const SWAP_HOP_CONST = -10
const SWAP_GRAV_CONST = 20

func _ready():
	randomize()
# warning-ignore:return_value_discarded
	get_node("/root/ChronoCrabs/GameControl").connect("race_started", self, "start_race")
# warning-ignore:return_value_discarded
	get_node("/root/ChronoCrabs/GameControl").connect("race_finished", self, "finish_race")
	world = get_node("/root/ChronoCrabs/World")
	current_shell = get_parent().get_parent()
	current_shell.occupied = true

	ready_to_swap = false

# warning-ignore:unused_argument
func _physics_process(delta):
	
	if racing == true:
		record_ghost()
		if swapping == false:
			get_crab_input()
	
	## swap shells movement
	if swapping == true:
		position.x += swap_velocity.x * delta## constant speed laterally
		position.y += swap_velocity.y
		swap_velocity.y += SWAP_GRAV_CONST * delta

func get_crab_input():
	## pause
	if Input.is_action_just_pressed("ui_cancel"):
		## TODO pause
		pass
	
	# swap shells
	if Input.is_action_just_pressed("ui_up"):
		if ready_to_swap == true:
			swap_shells(swap_target)
	
	## animation(s)
	if Input.is_action_just_released("ui_down"):
		$AnimationPlayer.playback_speed = 1.5
		$AnimationPlayer.play_backwards("withdraw")
		withdrawn = false
	
	if Input.is_action_pressed("ui_down"):
		$AntennaAnimationPlayer.stop(true)
		if withdrawn == false:
			withdrawn = true
			if $AnimationPlayer.current_animation == "withdraw":
				$AnimationPlayer.stop(false) ## pauses animation without resetting
			$AnimationPlayer.playback_speed = 1.5
			$AnimationPlayer.play("withdraw")
	else:
		if $AnimationPlayer.is_playing() && $AnimationPlayer.current_animation == "withdraw":
			pass
		else:
			if current_shell.upside_down == false:
				if Input.is_action_pressed("ui_right"):
					if $AnimationPlayer.current_animation != "walk":
						$AnimationPlayer.play("walk")
					$AnimationPlayer.playback_speed = current_shell.velocity.x * ANIM_WALK_CONST
				elif Input.is_action_pressed("ui_left"):
					if $AnimationPlayer.current_animation != "walk":
						$AnimationPlayer.play("walk")
					$AnimationPlayer.playback_speed = -current_shell.velocity.x * ANIM_WALK_CONST
				else:
					$AnimationPlayer.stop(false)
			else:
				current_shell.velocity.x = lerp(current_shell.velocity.x, 0, 0.2)

func record_ghost():
	## record ghost data: position, rotation, ?
	current_ghost[ghost_data_index] = [current_shell.global_position, current_shell.rotation_degrees, current_shell.facing_right]
	ghost_data_index += 1

func swap_shells(new_shell):
	print(str(new_shell.name))
	$AnimationPlayer.stop()
	if withdrawn == true:
		$AnimationPlayer.play_backwards("withdraw")
	$AnimationPlayer.play("swap_flip")
	$Camera2D.shell = new_shell
	$Camera2D.swapping = true
	current_shell.occupied = false
	current_container = get_node(str(get_path_to(current_shell)) + "/CrabContainer")
	new_container = get_node(str(get_path_to(new_shell)) + "/CrabContainer")
	swapping = true
	$SwapTimer.start()
	swap_velocity.x = new_shell.position.x - global_position.x
	swap_velocity.y = SWAP_HOP_CONST
	## TODO animate crab transition to new shell
	var current_global_pos = global_position
	current_container.remove_child(self)
	world.add_child(self)
	position = current_global_pos

func start_race():
	racing = true

func finish_race(elapsed):

	racing = false
	current_ghost["time_msec"] = elapsed

	if !game_data.ghost_data.has(game_data.track_data_index):
		## ...write ghost to game_data
		game_data.ghost_data[game_data.track_data_index] = current_ghost

	if current_ghost["time_msec"] < game_data.ghost_data[game_data.track_data_index]["time_msec"]:
		game_data.ghost_data[game_data.track_data_index] = current_ghost

func _on_Area2D_area_entered(area):
	## make sure it's a shell's area
	if area.get_parent().is_in_group("shell"):
		swap_target = area.get_parent()
		ready_to_swap = true

func _on_Area2D_area_exited(area):
	if area.get_parent().is_in_group("shell"):
		ready_to_swap = false

func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "withdraw":
		if withdrawn == false && current_shell.upside_down == true: 
			$AnimationPlayer.play("struggle")

func _on_SwapTimer_timeout():
	$SwapTimer.wait_time = 1
	$Camera2D.swapping = false
	swapping = false
	swap_velocity = Vector2()
	world.remove_child(self)
	new_container.add_child(self)
	current_container = new_container
	position = Vector2(40, -12)
	get_node(str(get_path_to(current_shell)) + "/Area2D/CollisionShape2D").disabled = false
	get_node(str(get_path_to(swap_target)) + "/Area2D/CollisionShape2D").disabled = true
	current_shell = swap_target
	current_shell.occupied = true

func _on_AntennaTimer_timeout():
	$AntennaTimer.wait_time = randi() % 3 + 1
	$AntennaTimer.start()
	if withdrawn == false:
		if randi() % 2 == 0:
			$AntennaAnimationPlayer.play("antenna_double_twitch")
		else:
			$AntennaAnimationPlayer.play("antenna_twitch")
