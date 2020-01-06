extends Node2D

# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	
func _physics_process(delta):
	pass

func build():
	add_track()
	add_players()
	if game_data.playing_with_ghost == true:
		add_ghosts()

func add_track():
	var track = load(game_data.track_data[game_data.track_data_index]).instance()
	add_child(track)

func add_players():
	for p in game_data.player_info:
		var player = load("res://Scenes/DumbPlayer.tscn").instance()
		player.set_name(str(p))
		player.set_network_master(p)
		player.position = Vector2(150, 250)
		add_child(player)

func add_ghosts():
	## TODO load all player ghosts, only each player's ghosts, or only fastest?
	
	var ghost = load("res://Scenes/Ghost.tscn").instance()
	ghost.position = Vector2(150, 325)
	add_child(ghost)

func destroy():
	for n in self.get_children():
		n.queue_free()