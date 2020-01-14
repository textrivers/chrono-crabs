extends CanvasLayer

var start_moment = 0
var current_moment = 0
var end_moment = 0

var elapsed = 0
var str_elapsed

var racing = false
var race_over = false

signal race_started
signal race_finished

var timer_countdown = 3
var timer_label

var lobby
var world
var player

func _ready():
	
	timer_label = get_node("TimerContainer/Label")
	get_node("/root/ChronoCrabs/Lobby").connect("start_game", self, "initiate_race")
	
func _on_Lobby_ready():
	lobby = get_node("/root/ChronoCrabs/Lobby")

func _on_World_ready():
	world = get_node("/root/ChronoCrabs/World")

func _physics_process(delta):
	
	current_moment = OS.get_ticks_msec()

	if racing == true:
		elapsed = current_moment - start_moment

	var minutes = (elapsed / 1000) / 60
	var seconds = (elapsed / 1000) % 60
	var milliseconds = elapsed % 1000
	
	str_elapsed = "%02d:%02d:%03d" % [minutes, seconds, milliseconds]

	timer_label.set_text(str_elapsed)

func initiate_race():
	## TODO move all game creation functions from Lobby to here,
	## hide menu
	$TrackSelectMenuContainer.hide()
	## add track, correct number of players, and ghosts
	world.build()
	world.show()
	
	## sync all (with yield/coroutine? See GDSCript basics page)
	
	## start race countdown sequence
	$TimerContainer.show()
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
		start_timing()
		emit_signal("race_started")

func start_timing():
	racing = true
	start_moment = OS.get_ticks_msec()

## TODO make this function responsive to player signal upon crossing finish line
func on_finish_line_crossed():
	racing = false
	end_moment = OS.get_ticks_msec()
	elapsed = end_moment - start_moment
	## send the elapsed time as a signal's argument, rather than setting the variable
	emit_signal("race_finished", elapsed)
	$PostRaceMenuContainer.show()

func reset_race():
	## hide Menu
	$PostRaceMenuContainer.hide()
	
	## reset vars
	start_moment = 0
	current_moment = 0
	end_moment = 0
	elapsed = 0
	str_elapsed = ""
	racing = false
	race_over = false
	
	$AudioStreamPlayer.pitch_scale = 1
	$StartingTimer.stop()
	$StartingTimer.wait_time = 1
	timer_countdown = 3
	
	## clear track, all players, and all ghosts
	world.destroy()

func _on_RaceGhost_pressed():
	
	reset_race()
	game_data.playing_with_ghost = true
	initiate_race()

func _on_RaceNoGhost_pressed():
	
	reset_race()
	game_data.playing_with_ghost = false
	initiate_race()

func _on_QuitToMenu_pressed():
	
	reset_race()
	
	lobby.hide()
	$TimerContainer.hide()
	$TrackSelectMenuContainer.hide()
	$MainMenuContainer.show()

func _on_SinglePlayer_pressed():
	$MainMenuContainer.hide()
	$TrackSelectMenuContainer.show()
	
func _on_Multiplayer_pressed():
	$MainMenuContainer.hide()
	lobby.show()

func _on_Options_pressed():
	$MainMenuContainer/Panel/Options.set_text("Options coming soon")

func _on_QuitToDesktop_pressed():
	get_tree().quit()

func _on_MainMenu_pressed():
	$TrackSelectMenuContainer.hide()
	$MainMenuContainer.show()
	
func _on_TrackList_item_selected(index):
	game_data.track_data_index = index
	## TODO add multiplayer selectability
	
	$TrackSelectMenuContainer/Panel/PlayAlready.disabled = false
	if game_data.ghost_data.has(game_data.track_data_index):
		$TrackSelectMenuContainer/Panel/GhostCheckbox.disabled = false
	else:
		$TrackSelectMenuContainer/Panel/GhostCheckbox.disabled = true

func _on_GhostCheckbox_toggled(button_pressed):
	if button_pressed == true:
		game_data.playing_with_ghost = true
	else:
		game_data.playing_with_ghost = false
