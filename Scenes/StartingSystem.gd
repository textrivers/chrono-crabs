extends Node2D

signal race_started

var timer_countdown = 3

var start_moment = 0
var current_moment = 0
var end_moment = 0

var racing = false

func _ready():
	## connect("Lobby.start_game", self, "start_race")
	## if is_connected("Lobby.start_game", self, "start_race"):
	## print("race start signal connected supposedly")
	get_node("/root/Lobby").connect("start_game", self, "start_race")

func _physics_process(delta):
	
	var elapsed
	
	current_moment = OS.get_unix_time()
	
	if racing == true:
		elapsed = current_moment - start_moment
	else: 
		elapsed = end_moment - start_moment
		
	print(elapsed)
		
	var minutes = elapsed / 60
	var seconds = elapsed % 60
	var milliseconds = 500
	
	get_tree().call_group("player", "display_time", minutes, seconds, milliseconds)

func start_race():
	
	## start race countdown timer
	$StartingTimer.start()
	
	

func _on_StartingTimer_timeout():
	print("time to start")
	
	if timer_countdown > 0: 
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
		racing = true
		start_timing()

func start_timing():
	start_moment = OS.get_unix_time()
	print(start_moment)
	
func finish_timing():
	racing = false
	end_moment = OS.get_unix_time()