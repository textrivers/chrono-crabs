extends CanvasLayer

var start_moment = 0
var current_moment = 0
var end_moment = 0

var elapsed = 0
var str_elapsed

var racing = false
var race_over = false

var timer_label
var lobby
var world
var player

func _ready():
	
	timer_label = get_node("TimerContainer/Label")
	lobby = get_node("/root/ChronoCrabs/Lobby")
	get_node("/root/ChronoCrabs/Lobby").connect("start_game", self, "start_game")

func _physics_process(delta):
	
	current_moment = OS.get_ticks_msec()

	if racing == true:
		elapsed = current_moment - start_moment

	var minutes = elapsed / 60000
	var seconds = elapsed / 1000
	var milliseconds = elapsed % 1000
	
	str_elapsed = "%02d:%02d:%03d" % [minutes, seconds, milliseconds]

	timer_label.set_text(str_elapsed)

func start_game():
	$TimerContainer.show()
	
	## find player 
	if game_data.world_path == "":
		player = get_node("/root/World/DumbPlayer")
	else:
		player = get_node(str(game_data.world_path) + "/DumbPlayer")

func start_timing():
	racing = true
	start_moment = OS.get_ticks_msec()

func on_finish_line_crossed():
	racing = false
	end_moment = OS.get_ticks_msec()
	elapsed = end_moment - start_moment
	player.current_ghost["time_msec"] = elapsed
	$MenuContainer.show()

func reset_playstate():
	## hide Menu
	$MenuContainer.hide()
	
	## reset vars
	start_moment = 0
	current_moment = 0
	end_moment = 0
	elapsed = 0
	str_elapsed = ""
	racing = false
	race_over = false
	
	$StartingSystem/AudioStreamPlayer.pitch_scale = 1
	$StartingSystem.timer_countdown = 3

func _on_RaceGhost_pressed():
	
	reset_playstate()
	
	## reload World
	world = get_node(game_data.world_path)
	world.queue_free()
	game_data.playing_with_ghost = true
	lobby._on_Solo_Button_pressed()

func _on_RaceNoGhost_pressed():
	
	reset_playstate()
	
	## reload World
	world = get_node(game_data.world_path)
	world.queue_free()
	game_data.playing_with_ghost = false
	lobby._on_Solo_Button_pressed()

func _on_QuitToMenu_pressed():
	
	reset_playstate()
	
	## hide menu, hide Timer 
	$TimerContainer.hide()
	
	## call _end_game from Lobby
	lobby._end_game()
	

func _on_QuitToDesktop_pressed():
	get_tree().quit()
