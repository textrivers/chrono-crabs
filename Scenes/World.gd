extends Node2D

signal game_finished

# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	

func input_handling():
	if Input.is_action_just_pressed("ui_cancel"):
		print("Escape pressed.")
		emit_signal("game_finished")
		
	
func _process(delta):
	input_handling()
