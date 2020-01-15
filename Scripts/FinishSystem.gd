extends Node2D

signal finish_line_crossed
var race_over = false

func _ready():
# warning-ignore:return_value_discarded
	self.connect("finish_line_crossed", get_node("/root/ChronoCrabs/GameControl"), "on_finish_line_crossed")


# warning-ignore:unused_argument
func _on_Area2D_body_entered(body):
	if race_over == false: 
	
		emit_signal("finish_line_crossed")
		$AudioStreamPlayer.play()
		race_over = true
