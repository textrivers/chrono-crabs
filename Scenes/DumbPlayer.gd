extends KinematicBody2D

export (int) var MAX_SPEED = 200
export (int) var accel = 10

var velocity = Vector2(0, 0)
var floor_normal = Vector2(0, -1)
var rolling = false
var gravity = 1600
var last_frame_pos = Vector2(0,0)
var pos_diff = 0

const REST_AMOUNT = 10
const ROTATION_CONST = 1.8

func _ready():
	pass

func get_floor_normal():
	floor_normal = $RayDown.get_collision_normal()

func get_input():
	if Input.is_action_pressed("ui_down"):
		rolling = true
		get_floor_normal()
		if floor_normal == Vector2(0, -1):
			if abs(velocity.x) > 5:
				velocity.x = lerp(velocity.x, 0, 0.01)
			else: 
				velocity.x = lerp(velocity.x, 0, 0.2)
	else:
		rolling = false
		if is_on_floor():
			if Input.is_action_pressed("ui_right"):
				velocity.x = min(velocity.x + accel, MAX_SPEED)
			elif Input.is_action_pressed("ui_left"):
				velocity.x = max(velocity.x - accel, -MAX_SPEED)
			else:
				velocity.x = lerp(velocity.x, 0, 0.2)
func move_player():
	## translation
	print(str(velocity.x))
	velocity = move_and_slide(velocity, floor_normal, true, 4, 0.8, true)
	
	## rotation
	if rolling: 
		pos_diff = position.x - last_frame_pos.x
		rotation_degrees += pos_diff * ROTATION_CONST
	else: rotation_degrees = lerp(rotation_degrees, 0, 0.05)
		

func _physics_process(delta):
	if !is_on_floor() or rolling:
		velocity.y += gravity * delta
	
	get_input()
	move_player()
	last_frame_pos.x = position.x
