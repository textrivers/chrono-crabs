extends Camera2D

var shell

# Called when the node enters the scene tree for the first time.
func _ready():
	## FIX for new player configuration
	shell = get_parent().get_parent().get_parent()

func _physics_process(delta):
	global_position = shell.global_position
	
	##zoom is 1 at 0 velocity and 2 maximum
	zoom.x = lerp(zoom.x, clamp((shell.velocity.x / 200), 1.0, 2.0), 0.01)
	zoom.y = zoom.x

	if shell.facing_right == true:
		offset.x = lerp(offset.x, 200, 0.01)
	else:
		offset.x = lerp(offset.x, -200, 0.01)
