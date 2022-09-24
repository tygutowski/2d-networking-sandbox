extends Node
var peer = NetworkedMultiplayerENet.new()
var player_state_collection = {}
var player_login_data = {}
var version = "1.0.0-alpha.2"

func start_server(max_players, port, seed_num):
	peer.create_server(int(port), int(max_players))
	get_tree().network_peer = peer
	print("server started")
	peer.connect("peer_connected", self, "_peer_connected")
	peer.connect("peer_disconnected", self, "_peer_disconnected")
	get_node("WorldGenerator").setup_world_generation(seed_num)

func _peer_connected(peer_id):
	
	print("peer: " + str(peer_id) + " connected")
	rpc_id(0, "spawn_player", peer_id) # spawns in all peers
	send_tilemap(peer_id, get_node("WorldGenerator").get_tilemap()) # send tilemap to master
	send_spawn_user(peer_id) # spawn the master in
	send_allow_user(peer_id) # allow master to move

remote func receive_client_version(client_version):
	var peer_id = get_tree().get_rpc_sender_id()
	if client_version != version:
		print("peer " + str(peer_id) + " is using version " + client_version + ", expected version " + version)
		send_version_error(peer_id, version)
remote func receive_player_login_data(username):
	var peer_id = get_tree().get_rpc_sender_id()
	player_login_data[peer_id] = username
	print("player login data: " + str(player_login_data))
	rpc_id(0, "set_names", player_login_data)

func send_version_error(peer_id, server_version):
	rpc_id(peer_id, "receive_version_error", server_version)

func _peer_disconnected(peer_id):
	print("peer: " + str(peer_id) + " disconnected")
	player_state_collection.erase(peer_id)
	rpc_id(0, "despawn_player", peer_id)

remote func receive_player_state(player_state):
	var peer_id = get_tree().get_rpc_sender_id()
	if player_state_collection.has(peer_id):
		if player_state_collection[peer_id]["T"] < player_state["T"]:
			player_state_collection[peer_id] = player_state
	else:
		player_state_collection[peer_id] = player_state

func send_world_state(world_state):
	rpc_unreliable_id(0, "receive_world_state", world_state)

func _on_Button_button_down():
	var max_players = get_node("CanvasLayer/Button/MaxPlayersInput").get_text()
	var port = get_node("CanvasLayer/Button/PortInput").get_text()
	var seed_number = get_node("CanvasLayer/Button/SeedInput").get_text()
	start_server(max_players, port, seed_number)
	get_node("CanvasLayer/Button").queue_free()

func send_tilemap(peer_id, tilemap_array):
	print("sending tilemap to peer: " + str(peer_id))
	rpc_id(peer_id, "receive_tilemap", tilemap_array, $WorldGenerator.worldStart, $WorldGenerator.worldEnd, $WorldGenerator.worldDepth, $WorldGenerator.skyLimit)

func send_spawn_user(peer_id):
	print("spawning in peer: " + str(peer_id))
	rpc_id(peer_id, "receive_spawn_user", player_login_data)

func send_allow_user(peer_id):
	print("enabling peer: " + str(peer_id))
	rpc_id(peer_id, "receive_allow_user")

remote func receive_tile_update(x, y, tile):
	print("tile update received")
	get_node("/root/Server/WorldGenerator").receive_tile_update(x, y, tile)

func send_small_tile_update(x, y, tile_id):
	rpc_id(0, "receive_small_tile_update", x, y, tile_id)
