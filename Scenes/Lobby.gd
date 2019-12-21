extends Control

const DEFAULT_PORT = 11880

var game_on = false

var player_info = { }
var my_name = "name string"
var my_id = 1

signal start_game

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

func _player_connected(id):
	print("_player_connected_called")
	
	my_id = SceneTree.get_unique_network_id()
	## change solo button text to PLAY
	## $Panel/Solo_Button.set_text("PLAY")
	
	# Called on both clients and server when a peer connects. Send my info to it.
	rpc("register_player", my_id, my_name)


func _player_disconnected(id):
	if get_tree().is_network_server():
		_end_game("Client disconnected")
	else:
		_end_game("Server disconnected")

func _connected_ok(): ## client only, not server
	print("_connected_ok() called")

func _connected_fail(): ## client only, not server
	_set_status("Couldn't connect", false)
	
	get_tree().set_network_peer(null) ## remove peer
	get_node("Panel/Join_Button").set_disabled(false)
	get_node("Panel/Host_Button").set_disabled(false)

func _server_disconnected():
	_end_game("Server disconnected")
	
### Game Creation functions ###

func _end_game(with_error=""):
	
	if has_node("/root/World"):
		## erase world, start over
		get_node("/root/World").free() ## immediate
		show()
		game_on = false
	
	get_tree().set_network_peer(null) ## remove peer
	$Panel/Join_Button.set_disabled(false)
	$Panel/Host_Button.set_disabled(false)
	$Panel/Solo_Button.set_disabled(false)
	_set_status(with_error, false)

func _set_status(text, isok):
	## simple way to show status
	if isok:
		$Panel/Status_OK.set_text(text)
		$Panel/Status_Fail.set_text("")
	else:
		$Panel/Status_OK.set_text("")
		$Panel/Status_Fail.set_text(text)

remote func register_player(their_id, their_name):
	## register self
	player_info[my_id] = my_name
	
	## register player who just sent me their info
	player_info[their_id] = their_name
	
	print(player_info)
	
	## TODO make the Lobby display update with player info
	

func _on_Host_Button_pressed():
	my_name = $Panel/Name.get_text()
	if my_name == "":
		_set_status("Please enter a name", false)
		return
	
	var ip = get_node("Panel/Address").get_text()
	if not ip.is_valid_ip_address():
		_set_status("IP address is invalid", false)
		return
	
	## $Panel/Solo_Button.set_text("PLAY")
	var host = NetworkedMultiplayerENet.new()
	host.set_compression_mode(NetworkedMultiplayerENet.COMPRESS_RANGE_CODER)
	var err = host.create_server(DEFAULT_PORT, 3)
	if err != OK:
		## another server running?
		_set_status("Can't host, address in use.", false)
		return
	
	get_tree().set_network_peer(host)
	$Panel/Join_Button.set_disabled(true)
	$Panel/Host_Button.set_disabled(true)
	_set_status("Waiting for players...", true)
	
	get_node("Panel/Player1_Connected").set_text(my_name + " is hosting")
	
	player_info[1] = my_name

func _on_Join_Button_pressed():
	my_name = $Panel/Name.get_text()
	if my_name == "":
		_set_status("Please enter a name", false)
		return
		
	var ip = get_node("Panel/Address").get_text()
	if not ip.is_valid_ip_address():
		_set_status("IP address is invalid", false)
		return
	
	var host = NetworkedMultiplayerENet.new()
	host.set_compression_mode(NetworkedMultiplayerENet.COMPRESS_RANGE_CODER)
	host.create_client(ip, DEFAULT_PORT)
	get_tree().set_network_peer(host)
	
	_set_status("Connecting...", true)

func _on_Solo_Button_pressed():
	## load game
	var game_world = load("res://Scenes/World.tscn").instance()
	game_world.connect("game_finished", self, "_end_game", [], CONNECT_DEFERRED) ## deferred so it can be safely erased...?
	##start game
	get_tree().get_root().add_child(game_world)
	
	game_on = true
	
	emit_signal("start_game")
	print("game start signal sent")
	
	## hide lobby
	hide()
	
	

# warning-ignore:unused_argument
func _process(delta):
	if Input.is_action_just_pressed("ui_cancel"):
		if game_on == false: 
			get_tree().quit()