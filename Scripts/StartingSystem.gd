extends Node2D



func _ready():
	self.connect("race_started", get_node(".."), "start_timing")

func _physics_process(delta):
	
	## if racing == false:
		## racing = true
	pass

func start_countdown():

	## start race countdown timer
	


