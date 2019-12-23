extends Node2D

signal game_finished
var start_moment = 0
var current_moment = 0
var end_moment = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	

func input_handling():
	if Input.is_action_just_pressed("ui_cancel"):
		print("Escape pressed.")
		emit_signal("game_finished")
		
	
func _physics_process(delta):
	input_handling()
	current_moment = OS.get_unix_time()
	
