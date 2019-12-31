extends Node2D

signal race_finished
var race_over = false

func _ready():
	self.connect("race_finished", get_node("/root/ChronoCrabs/GameControl"), "on_finish_line_crossed")
	self.connect("race_finished", get_node("/root/World/DumbPlayer"), "finish_race")
	

func _on_Area2D_body_entered(body):
	if race_over == false: 
	
		emit_signal("race_finished")
		$AudioStreamPlayer.play()
		race_over = true
