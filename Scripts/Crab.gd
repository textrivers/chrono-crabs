extends Node2D

var racing = false
var current_ghost = {}
var ghost_data_index = 0

var current_shell

var swap_target
var ready_to_swap = false

var withdrawn = false

const ANIM_WALK_CONST = 0.015

func _ready():
# warning-ignore:return_value_discarded
	get_node("/root/ChronoCrabs/GameControl").connect("race_started", self, "start_race")
# warning-ignore:return_value_discarded
	get_node("/root/ChronoCrabs/GameControl").connect("race_finished", self, "finish_race")
	current_shell = get_parent().get_parent()
	current_shell.occupied = true


# warning-ignore:unused_argument
func _physics_process(delta):
	get_crab_input()
	record_ghost()

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
	if Input.is_action_pressed("ui_down"):
		if withdrawn == false:
			withdrawn = true
			if $AnimationPlayer.current_animation == "withdraw":
				$AnimationPlayer.stop(false) ## pauses animation without resetting
			$AnimationPlayer.playback_speed = 1.5
			$AnimationPlayer.play("withdraw")
	else:
		if withdrawn == true:
			withdrawn = false
			if $AnimationPlayer.current_animation == "withdraw":
				$AnimationPlayer.stop(false) ## pauses animation without resetting
			$AnimationPlayer.playback_speed = 1.5
			$AnimationPlayer.play_backwards("withdraw")
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
				$AnimationPlayer.play("rest")
		else:
			current_shell.velocity.x = lerp(current_shell.velocity.x, 0, 0.2)

func record_ghost():
	if racing == true:
		## record ghost data: position, rotation, ?
		current_ghost[ghost_data_index] = [current_shell.global_position, current_shell.rotation_degrees, current_shell.facing_right]
		ghost_data_index += 1

func swap_shells(new_shell):
	print("swap shells called")
	$AnimationPlayer.stop()
	$Camera2D.shell = new_shell
	current_shell.occupied = false
	new_shell.occupied = true
	## TODO animate crab transition to new shell
	var current_container = get_node(str(get_path_to(current_shell)) + "/CrabContainer")
	var new_container = get_node(str(get_path_to(new_shell)) + "/CrabContainer")
	current_container.remove_child(self)
	new_container.add_child(self)
	get_node(str(get_path_to(current_shell)) + "/Area2D/CollisionShape2D").disabled = false
	get_node(str(get_path_to(new_shell)) + "/Area2D/CollisionShape2D").disabled = true
	current_shell = new_shell

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
	print("area entered")
	## make sure it's a shell's area
	if area.get_parent().is_in_group("shell"):
		swap_target = area.get_parent()
		ready_to_swap = true
		## TODO turn on up-arrow graphic to cue player to swap

func _on_Area2D_area_exited(area):
	print("area exited")
	if area.get_parent().is_in_group("shell"):
		ready_to_swap = false

func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "withdraw":
		if withdrawn == false && current_shell.upside_down == true: 
			$AnimationPlayer.play("struggle")
