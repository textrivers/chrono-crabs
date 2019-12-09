extends RigidBody2D

export (int) var speed = 120

var velocity = Vector2(0, 0)

const REST_AMOUNT = 10

func _ready():
	pass

func get_input():
	velocity.x = 0
	if Input.is_action_pressed("ui_right"):
		velocity.x += speed
	else:
		if velocity.x > 0:
			velocity.x -= speed
	if Input.is_action_pressed("ui_left"):
		velocity.x -= speed
	else:
		if velocity.x < 0:
			velocity.x += speed
	if Input.is_action_pressed("ui_down"):
		print("down pressed")

func _physics_process(delta):
	get_input()
	add_force(Vector2(0, 0), velocity)
