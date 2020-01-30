extends Sprite

var direction

const ROT_CONST = 0.1

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	direction = randi() % 2
	if direction == 0:
		direction = -1

func _process(delta):
	$Aura1.rotation_degrees += (ROT_CONST * direction)
	$Aura2.rotation_degrees -= (ROT_CONST * direction)
