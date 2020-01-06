extends KinematicBody2D

export (int) var MAX_SPEED = 200
export (int) var accel = 10

var velocity = Vector2(0, 0)
var floor_normal = Vector2(0, -1)
var rolling = false
var gravity = 1600
var last_frame_pos = Vector2(0,0)
var pos_diff = 0
var flipped = false
var flip_now = false

var racing = true
var current_ghost = {}
var ghost_data_index = 0

const ROTATION_CONST = 1.8
const CAMERA_OFFSET_SPEED = 1

func _ready():
	## get_node("/root/World/BasicDownhillTrack/FinishSystem").connect("race_finished", self, "finish_race")
	## get_node("/root/ChronoCrabs/GameControl").connect("race_started", self, "start_race")
	## get_node("/root/ChronoCrabs/GameControl").connect("race_finished", self, "finish_race")
	pass

func get_floor_normal():
	if $RayDown.is_colliding():
		floor_normal = $RayDown.get_collision_normal()

func get_input():
	if Input.is_action_just_pressed("ui_cancel"):
		## TODO pause 
		pass
	
	if Input.is_action_pressed("ui_down"):
		rolling = true
		flip_now = false
		if floor_normal == Vector2(0, -1):
			if abs(velocity.x) > 5:
				velocity.x = lerp(velocity.x, 0, 0.01)
			else: 
				velocity.x = lerp(velocity.x, 0, 0.2)
	else:
		rolling = false
		if is_on_floor():
			if flipped == false:
				if Input.is_action_pressed("ui_right"):
					$Sprite2.flip_h = false
					velocity.x = min(velocity.x + accel, MAX_SPEED)
				elif Input.is_action_pressed("ui_left"):
					$Sprite2.flip_h = true
					velocity.x = max(velocity.x - accel, -MAX_SPEED)
				else:
					velocity.x = lerp(velocity.x, 0, 0.2)
			else: 
				velocity.x = lerp(velocity.x, 0, 0.2)
func move_player():
	
	## translation
	velocity = move_and_slide(velocity, floor_normal, true, 4, 0.8, true)
	
	## rotation
	if rolling: 
		pos_diff = position.x - last_frame_pos.x
		rotation_degrees += pos_diff * ROTATION_CONST
	else: 
		if $RayDown.is_colliding() || flip_now == true:
			rotation_degrees = lerp(rotation_degrees, rad2deg(floor_normal.angle()) + 90, 0.2)
		else:
			## timer for flipping upright
			if $FlipTimer.is_stopped():
				flip_now = false
				flipped = true
				$FlipTimer.start()
				
	last_frame_pos.x = position.x

func adjust_camera_offset():
	$Camera2D.offset.x = lerp($Camera2D.offset.x, clamp(velocity.x, 100, 300), 0.03)
	$Camera2D.offset.y = lerp($Camera2D.offset.y, clamp(velocity.y, 0, 200), 0.03)

func record_ghost():
	if racing == true:
		## record ghost data: position, rotation, ?
		current_ghost[ghost_data_index] = [position, rotation_degrees, $Sprite2.flip_h]
		ghost_data_index += 1

func _physics_process(delta):
	
	get_floor_normal()
	if !is_on_floor() or rolling:
		velocity.y += gravity * delta
	
	if racing == true:
		get_input()
	
	move_player()
	
	adjust_camera_offset()
	
	record_ghost()
	

func _on_FlipTimer_timeout():
	$FlipTimer.stop()
	flip_now = true
	flipped = false
	
func start_race():
	racing = true
	
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