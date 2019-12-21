extends Node2D

signal race_started

var timer_countdown = 3

func _ready():
	connect("Lobby.start_game", self, "start_race")
	if is_connected("Lobby.start_game", self, "start_race"):
		print("race start signal connected supposedly")

func _physics_process(delta):
	pass

func start_race():
	print("game start signal received")
	## start race countdown timer
	$StartingTimer.start()

func _on_StartingTimer_timeout():
	
	if timer_countdown < 0: 
		$AudioStreamPlayer2D.play()
		timer_countdown -= 1
		$StartingTimer.start()
	elif timer_countdown == 0:
		## high beep
		$AudioStreamPlayer2D.pitch_scale = 2
		$AudioStreamPlayer2D.play()
		## race starts
		$StartingTimer.stop()
		emit_signal("race_started")
