extends Camera2D

var shell

# Called when the node enters the scene tree for the first time.
func _ready():
	shell = get_node("..")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	##zoom is 1 at 0 velocity and 2 maximum
	zoom.x = lerp(zoom.x, clamp((shell.velocity.x / 200), 1.0, 2.0), 0.01)
	zoom.y = zoom.x
	
	if shell.facing_right == true:
		offset.x = lerp(offset.x, 200, 0.01)
	else: 
		offset.x = lerp(offset.x, -200, 0.01)
	