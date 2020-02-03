extends Node2D

var game_control

# Called when the node enters the scene tree for the first time.
func _ready():
	game_control = get_node("/root/ChronoCrabs/GameControl")
	
# warning-ignore:unused_argument
func _physics_process(delta):
	if Input.is_action_pressed("ui_cancel"):
		game_control._on_QuitToMenu_pressed()

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
		var player = load("res://Scenes/Shell.tscn").instance()
		player.set_name(str(p))
		player.set_network_master(p)
		player.position = Vector2(150, 200)
		add_child(player)
		
		var crab = load("res://Scenes/Crab.tscn").instance()
		get_node(str(get_path_to(player)) + "/CrabContainer").add_child(crab)
		## set crab position appropriately

func add_ghosts():
	if game_data.ghost_data.has(game_data.track_data_index):
		var ghost = load("res://Scenes/Ghost.tscn").instance()
		add_child(ghost)

func destroy():
	for n in self.get_children():
		n.queue_free()
