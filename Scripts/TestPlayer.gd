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

var world
var track

var racing = false
var occupied = false
var can_swap = false
var swap_target = ""

const ROTATION_CONST = 1.8

func _ready():
	## get_node("/root/World/BasicDownhillTrack/FinishSystem").connect("race_finished", self, "finish_race")
	get_node("/root/ChronoCrabs/GameControl").connect("race_started", self, "start_race")
	get_node("/root/ChronoCrabs/GameControl").connect("race_finished", self, "finish_race")
	
	## accessing world variable for later
	world = get_node("/root/ChronoCrabs/World")
	track = get_node("..")
	
	## disable Area2D for player
	if get_node("..").is_in_group("player"):
		$Area2D/CollisionShape2D.disabled = true
		$Sprite2/Sprite2.show()
		occupied = true

func get_floor_normal():
	if $RayDown.is_colliding():
		floor_normal = $RayDown.get_collision_normal()

func get_input():
	if Input.is_action_just_pressed("ui_cancel"):
		## TODO pause
		pass

	if Input.is_action_pressed("ui_down"):
		$Sprite2/Sprite2.hide()
		rolling = true
		flip_now = false
		if floor_normal == Vector2(0, -1):
			if abs(velocity.x) > 5:
				velocity.x = lerp(velocity.x, 0, 0.01)
			else:
				velocity.x = lerp(velocity.x, 0, 0.2)
	else:
		$Sprite2/Sprite2.show()
		rolling = false
		if is_on_floor():
			if flipped == false:
				if Input.is_action_pressed("ui_right"):
					$Sprite2.flip_h = false
					$Sprite2/Sprite2.flip_h = false
					velocity.x = min(velocity.x + accel, MAX_SPEED)
				elif Input.is_action_pressed("ui_left"):
					$Sprite2.flip_h = true
					$Sprite2/Sprite2.flip_h = true
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

func swap_shells():
	can_swap = false
	for n in swap_target.get_children():
		if n.is_in_group("shell"):
			n.racing = false
			n.can_swap = true
			n.occupied = false
			swap_target.remove_child(n)
			## TODO next line is a problem. Don't know why adding the other shell to the world, or the track, breaks the game.
			## Maybe this all would work better if the parent script was initiating all of it
			## track.add_child(n, true)
	track.remove_child(self)
	swap_target.add_child(self, true)
	swap_target.current_shell = get_node(".")
	$Area2D/CollisionShape2D.disabled = true
	$Sprite2/Sprite2.show()
	occupied = true

func _physics_process(delta):
	get_floor_normal()
	
	if !is_on_floor() or rolling:
			velocity.y += gravity * delta
	
	if occupied == true:
		
		if racing == true:
			get_input()
	
	move_player()
	
	if can_swap == true:
		if Input.is_action_just_pressed("ui_up"):
			swap_shells()

func _on_FlipTimer_timeout():
	$FlipTimer.stop()
	flip_now = true
	flipped = false

func start_race():
	racing = true

func finish_race(elapsed):
	racing = false

func _on_Area2D_body_entered(body):
	## get the parent of the thing that entered the area
	swap_target = get_node(str(get_path_to(body))).get_parent()
	if swap_target.is_in_group("player"):
		can_swap = true
		## TODO turn on up-arrow graphic to cue player to swap

func _on_Area2D_body_exited(body):
	if get_node(str(get_path_to(body))).is_in_group("shell"):
		can_swap = false
