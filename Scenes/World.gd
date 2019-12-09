extends Node2D

# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	

func input_handling():
	if Input.is_action_pressed("ui_cancel"):
		print("Escape pressed.")
		get_tree().quit()
		
	
func _process(delta):
	input_handling()
