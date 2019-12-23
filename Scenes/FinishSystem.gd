extends Node2D

signal race_finished

func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Area2D_body_entered(body):
	emit_signal("race_finished")
	$AudioStreamPlayer2D.play()
