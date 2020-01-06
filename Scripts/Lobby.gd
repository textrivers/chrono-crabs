extends Control

const DEFAULT_PORT = 11880

var game_on = false

var player_info = { }
var my_name = "name string"

signal start_game

var world
var game_control

func _ready():

	game_control = get_node("../GameControl")

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

func _on_World_ready():
	world = get_node("/root/ChronoCrabs/World")

### Network callback functions ###

func _player_connected(id):
	
	## change solo button text to PLAY
	$Panel/Solo_Button.set_text("PLAY")
	
	## register self
	player_info[id] = my_name
	
	# Called on both clients and server when a peer connects. Send my info to it.
	rpc("register_player", id, my_name)

func _player_disconnected(id):
	if get_tree().is_network_server():
		_end_game("Client disconnected")
	else:
		_end_game("Server disconnected")

func _connected_ok(): ## client only, not server
	$Panel/Solo_Button.set_text("PLAY")

func _connected_fail(): ## client only, not server
	_set_status("Couldn't connect", false)
	
	get_tree().set_network_peer(null) ## remove peer
	get_node("Panel/Join_Button").set_disabled(false)
	get_node("Panel/Host_Button").set_disabled(false)

func _server_disconnected():
	_end_game("Server disconnected")
	
### Game Creation functions ###

func _end_game(with_error=""):
	
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
	
	## register player who just sent me their info
	player_info[their_id] = their_name
	
	var info_index = 1
	
	for i in player_info:
		if get_node("Panel/Player_" + str(info_index)).get_text() == "":
			get_node("Panel/Player_" + str(info_index)).set_text(player_info[i] + " connected")
		info_index += 1 

func _on_Host_Button_pressed():
	$Panel/Solo_Button.set_text("PLAY")
	
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
	var err = host.create_server(DEFAULT_PORT, 3)
	if err != OK:
		## another server running?
		_set_status("Can't host, address in use.", false)
		return
	
	get_tree().set_network_peer(host)
	$Panel/Join_Button.set_disabled(true)
	$Panel/Host_Button.set_disabled(true)
	_set_status("Waiting for players...", true)
	
	get_node("Panel/Player_1").set_text(my_name + " is hosting")
	
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
	
	var join = NetworkedMultiplayerENet.new()
	join.set_compression_mode(NetworkedMultiplayerENet.COMPRESS_RANGE_CODER)
	join.create_client(ip, DEFAULT_PORT)
	get_tree().set_network_peer(join)
	
	_set_status("Connecting...", true)

func _on_Solo_Button_pressed():
	## TODO move game_on tracking to GameControl
	game_on = true
	
	## make player_info accessible
	game_data.player_info = player_info
	
	## hide lobby
	hide()
	
	## show TrackSelectMenu
	game_control.TrackSelectMenuContainer.show()
	
	

# warning-ignore:unused_argument
func _process(delta):
	if Input.is_action_just_pressed("ui_cancel"):
		if game_on == false: 
			get_tree().quit()

