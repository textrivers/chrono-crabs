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

var racing = false
var occupied = false

const ROTATION_CONST = 1.8


func _ready():
	## get_node("/root/World/BasicDownhillTrack/FinishSystem").connect("race_finished", self, "finish_race")
# warning-ignore:return_value_discarded
	get_node("/root/ChronoCrabs/GameControl").connect("race_started", self, "start_race")
# warning-ignore:return_value_discarded
	get_node("/root/ChronoCrabs/GameControl").connect("race_finished", self, "finish_race")

	## disable Area2D for player
	if occupied == true:
		$Area2D/CollisionShape2D.disabled = true
	else:
		$Area2D/CollisionShape2D.disabled = false

func get_floor_normal():
	## keep RayDown pointing straight down
	$RayFloor.rotation_degrees = -rotation_degrees
	
	if $RayDown.is_colliding():
		floor_normal = $RayDown.get_collision_normal()
	elif $RayFloor.is_colliding():
		floor_normal = $RayFloor.get_collision_normal()

func get_input():

	## shell movement
	if Input.is_action_pressed("ui_down"):
		rolling = true
		flip_now = false
		if floor_normal == Vector2(0, -1):
			if abs(velocity.x) > 5:
				velocity.x = lerp(velocity.x, 0, 0.01)
			else:
				velocity.x = lerp(velocity.x, 0, 0.1)
	else:
		rolling = false
		if is_on_floor():
			if upside_down == false:
				if Input.is_action_pressed("ui_right"):
					facing_right = true
					## $ShellSprite.scale.x = abs($ShellSprite.scale.x)
					velocity.x = min(velocity.x + accel, MAX_SPEED)
				elif Input.is_action_pressed("ui_left"):
					facing_right = false
					## $ShellSprite.scale.x = -abs($ShellSprite.scale.x)
					velocity.x = max(velocity.x - accel, -MAX_SPEED)
				else:
					velocity.x = lerp(velocity.x, 0, 0.2)
			else:
				velocity.x = lerp(velocity.x, 0, 0.2)
		else:
			velocity.x = lerp(velocity.x, 0, 0.01)

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

func _physics_process(delta):
	if facing_right == true:
		$CrabContainer.scale.x = lerp($CrabContainer.scale.x, 1, 0.3)
	else:
		$CrabContainer.scale.x = lerp($CrabContainer.scale.x, -1, 0.3)
	
	get_floor_normal()

	if !is_on_floor() || rolling == true:
			velocity.y += gravity * delta

	if racing == true:
		if occupied == true:
			get_input()
		else:
			velocity.x = lerp(velocity.x, 0, 0.2)
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

func _on_Area2D_area_entered(area):
	if occupied == false:
		if area.is_in_group("player"):
			$CrabContainer/Sprite.show()

func _on_Area2D_area_exited(area):
	if area.is_in_group("player"):
		$CrabContainer/Sprite.hide()
