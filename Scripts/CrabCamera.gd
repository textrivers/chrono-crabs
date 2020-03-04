extends Camera2D

var shell
var swapping = false

# Called when the node enters the scene tree for the first time.
func _ready():
	## FIX for new player configuration
	shell = get_parent().get_parent().get_parent()

func _physics_process(_delta):
	if swapping == true:
		pass
	else:
		global_position.x = shell.global_position.x
		global_position.y = shell.global_position.y - 200
		
		##zoom is 1 at 0 velocity and 2 maximum
		zoom.x = lerp(zoom.x, clamp((shell.velocity.x / 200), 1.0, 2.0), 0.01)
		zoom.y = zoom.x

	if shell.facing_right == true:
		offset.x = lerp(offset.x, 200, 0.01)
	else:
		offset.x = lerp(offset.x, -200, 0.01)
