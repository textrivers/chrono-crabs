extends Node2D

signal race_started

var timer_countdown = 3

var racing = false

func _ready():
	## connect("Lobby.start_game", self, "start_race")
	## if is_connected("Lobby.start_game", self, "start_race"):
	## print("race start signal connected supposedly")
	get_node("/root/ChronoCrabs/Lobby").connect("start_game", self, "start_race")
	self.connect("race_started", get_node(".."), "start_timing")

func _physics_process(delta):
	
	## if racing == false:
		## racing = true
	pass

func start_race():
	
	## start race countdown timer
	$StartingTimer.start()

func _on_StartingTimer_timeout():
	
	if timer_countdown > 0: 
		$AudioStreamPlayer.play()
		timer_countdown -= 1
	elif timer_countdown == 0:
		## high beep
		$AudioStreamPlayer.pitch_scale = 2
		$AudioStreamPlayer.play()
		## race starts
		$StartingTimer.stop()
		emit_signal("race_started")
