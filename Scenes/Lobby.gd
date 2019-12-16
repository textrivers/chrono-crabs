extends Control

const DEFAULT_PORT = 11880

var game_on = false

func _ready():
	# connect all the callbacks related to networking

# warning-ignore:return_value_discarded
	get_tree().connect("network_peer_connected", self, "_player_connected")
# warning-ignore:return_value_discarded
	get_tree().connect("network_peer_disconnected", self, "_player_disconnected")
# warning-ignore:return_value_discarded
	get_tree().connect("connected_to_server", self, "_connected_ok")
# warning-ignore:return_value_discarded
	get_tree().connect("connection_failed", self, "_connected_fail")
# warning-ignore:return_value_discarded
	get_tree().connect("server_disconnected", self, "_server_disconnected")

### Network callback functions ###

func _player_connected(_id):
	## someone connected, start the game! 
	var game_world = load("res://Scenes/World.tscn").instance()
	game_world.connect("game_finished", self, "_end_game", [], CONNECT_DEFERRED) ## deferred so it can be safely erased...?
	
	##start game
	get_tree().get_root().add_child(game_world)
	## hide lobby
	hide()
	game_on = true

func _player_disconnected(_id):
	if get_tree().is_network_server():
		_end_game("Client disconnected")
	else:
		_end_game("Server disconnected")

func _connected_ok(): ## client only, not server
	## not used for some reason?
	pass

func _connected_fail(): ## client only, not server
	_set_status("Couldn't connect", false)
	
	get_tree().set_network_peer(null) ## remove peer
	get_node("Panel/Join_Button").set_disabled(false)
	get_node("Panel/Host_Button").set_disabled(false)

func _server_disconnected():
	_end_game("Server disconnected")
	
### Game Creation functions ###

func _end_game(with_error=""):
	print("I ended the game")
	if has_node("/root/World"):
		## erase world, start over
		get_node("/root/World").free() ## immediate
		show()
		game_on = false
	
	get_tree().set_network_peer(null) ## remove peer
	get_node("Panel/Join_Button").set_disabled(false)
	get_node("Panel/Host_Button").set_disabled(false)
	get_node("Panel/Status_1_Player").hide()
	_set_status(with_error, false)

func _set_status(text, isok):
	## simple way to show status
	if isok:
		get_node("Panel/Status_OK").set_text(text)
		get_node("Panel/Status_Fail").set_text("")
	else:
		get_node("Panel/Status_OK").set_text("")
		get_node("Panel/Status_Fail").set_text(text)

func _on_Host_Button_pressed():
	var host = NetworkedMultiplayerENet.new()
	host.set_compression_mode(NetworkedMultiplayerENet.COMPRESS_RANGE_CODER)
	var err = host.create_server(DEFAULT_PORT, 3)
	if err != OK:
		## another server running?
		_set_status("Can't host, address in use.", false)
		return
	
	get_tree().set_network_peer(host)
	get_node("Panel/Join_Button").set_disabled(true)
	get_node("Panel/Host_Button").set_disabled(true)
	get_node("Panel/Status_1_Player").show()
	_set_status("Waiting for player...", true)

func _on_Join_Button_pressed():
	var ip = get_node("Panel/Address").get_text()
	if not ip.is_valid_ip_address():
		_set_status("IP address is invalid", false)
		return
	
	var host = NetworkedMultiplayerENet.new()
	host.set_compression_mode(NetworkedMultiplayerENet.COMPRESS_RANGE_CODER)
	host.create_client(ip, DEFAULT_PORT)
	get_tree().set_network_peer(host)
	
	_set_status("Connecting...", true)
	
# warning-ignore:unused_argument
func _process(delta):
	if Input.is_action_just_pressed("ui_cancel"):
		if game_on == false: 
			get_tree().quit()

func _on_Status_1_Player_pressed():
	_player_connected(1)
