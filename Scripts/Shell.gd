extends KinematicBody2D

export (int) var MAX_SPEED = 200
export (int) var accel = 10

var velocity = Vector2(0, 0)
var floor_normal = Vector2(0, -1)
var rolling = false
var gravity = 1600
var last_frame_pos = Vector2(0,0)
var pos_diff = 0

var facing_right = true
var upside_down = false
var flip_now = false
var withdrawn = false

var world
var player

var racing = false
var occupied = false
var can_swap = false
var swap_target = ""
signal swap_now(shell)

const ROTATION_CONST = 1.8
const ANIM_WALK_CONST = 0.015

func _ready():
	## get_node("/root/World/BasicDownhillTrack/FinishSystem").connect("race_finished", self, "finish_race")
# warning-ignore:return_value_discarded
	get_node("/root/ChronoCrabs/GameControl").connect("race_started", self, "start_race")
# warning-ignore:return_value_discarded
	get_node("/root/ChronoCrabs/GameControl").connect("race_finished", self, "finish_race")

	## accessing world variable for later
	world = get_node("/root/ChronoCrabs/World")

	## disable Area2D for player
	if get_node("..").is_in_group("player"):
		player = get_node("..")
		$Area2D/CollisionShape2D.disabled = true
		$ShellSprite/Crab.show()
		occupied = true

func get_floor_normal():
	## keep RayDown pointing straight down
	$RayFloor.rotation_degrees = -rotation_degrees
	
	if $RayDown.is_colliding():
		floor_normal = $RayDown.get_collision_normal()
	elif $RayFloor.is_colliding():
		floor_normal = $RayFloor.get_collision_normal()

func get_input():
	if Input.is_action_just_pressed("ui_cancel"):
		## TODO pause
		pass

	if Input.is_action_pressed("ui_down"):
		if withdrawn == false:
			withdrawn = true
			if $ShellSprite/Crab/AnimationPlayer.current_animation == "withdraw":
				$ShellSprite/Crab/AnimationPlayer.stop(false) ## pauses animation without resetting
			$ShellSprite/Crab/AnimationPlayer.playback_speed = 1.5
			$ShellSprite/Crab/AnimationPlayer.play("withdraw")
		rolling = true
		flip_now = false
		if floor_normal == Vector2(0, -1):
			if abs(velocity.x) > 5:
				velocity.x = lerp(velocity.x, 0, 0.01)
			else:
				velocity.x = lerp(velocity.x, 0, 0.1)
	else:
		if withdrawn == true:
			withdrawn = false
			if $ShellSprite/Crab/AnimationPlayer.current_animation == "withdraw":
				$ShellSprite/Crab/AnimationPlayer.stop(false) ## pauses animation without resetting
			$ShellSprite/Crab/AnimationPlayer.playback_speed = 1.5
			$ShellSprite/Crab/AnimationPlayer.play_backwards("withdraw")
		rolling = false
		if is_on_floor():
			if upside_down == false:
				if Input.is_action_pressed("ui_right"):
					facing_right = true
					$ShellSprite.scale.x = abs($ShellSprite.scale.x)
					velocity.x = min(velocity.x + accel, MAX_SPEED)
					if $ShellSprite/Crab/AnimationPlayer.current_animation != "walk":
						$ShellSprite/Crab/AnimationPlayer.play("walk")
					$ShellSprite/Crab/AnimationPlayer.playback_speed = velocity.x * ANIM_WALK_CONST
				elif Input.is_action_pressed("ui_left"):
					facing_right = false
					$ShellSprite.scale.x = -abs($ShellSprite.scale.x)
					velocity.x = max(velocity.x - accel, -MAX_SPEED)
					if $ShellSprite/Crab/AnimationPlayer.current_animation != "walk":
						$ShellSprite/Crab/AnimationPlayer.play("walk")
					$ShellSprite/Crab/AnimationPlayer.playback_speed = -velocity.x * ANIM_WALK_CONST
				else:
					velocity.x = lerp(velocity.x, 0, 0.2)
					$ShellSprite/Crab/AnimationPlayer.play("rest")
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
				upside_down = true
				$FlipTimer.start()

	last_frame_pos.x = position.x

func swap_shells():
	can_swap = false
	$Area2D/CollisionShape2D.disabled = true
	occupied = true
	## TODO swap animation
	$ShellSprite/Crab/AnimationPlayer.stop()
	$ShellSprite/Crab.show()
	racing = true
	var glob_pos = global_position
	get_parent().remove_child(self)
	swap_target.add_child(self)
	player = swap_target
	global_position = glob_pos
	emit_signal("swap_now", self)

func _physics_process(delta):
	get_floor_normal()

	if !is_on_floor() || rolling == true:
			velocity.y += gravity * delta

	if racing == true:
		if occupied == true:
			get_input()
		else:
			velocity.x = lerp(velocity.x, 0, 0.2)
		
		if can_swap == true:
			if Input.is_action_just_pressed("ui_up"):
				swap_shells()
	else: 
		velocity.x = lerp(velocity.x, 0, 0.2)
	
	move_player()


func _on_FlipTimer_timeout():
	$FlipTimer.stop()
	flip_now = true
	upside_down = false

func start_race():
	racing = true

# warning-ignore:unused_argument
func finish_race(elapsed):
	racing = false
	$ShellSprite/Crab/AnimationPlayer.play("rest")

func _on_Area2D_body_entered(body):
	## get the parent of the thing that entered the area
	if body.get_parent().is_in_group("player"):
		swap_target = body.get_parent()
		print(str(body) + " entered area of " + str(self.name))
		can_swap = true
		if !is_connected("swap_now", swap_target, "swap_shells"):
# warning-ignore:return_value_discarded
			self.connect("swap_now", swap_target, "swap_shells")
		## TODO turn on up-arrow graphic to cue player to swap

func _on_Area2D_body_exited(body):
	if body.is_in_group("shell"):
		print(str(body) + " exited area of " + str(self.name))
		can_swap = false
