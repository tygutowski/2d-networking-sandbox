extends Node

var peer = NetworkedMultiplayerENet.new()
var version = "1.0.0-alpha.2"

func _connect(port, ip, username):
	_create_client(port, ip)
	yield(get_tree().create_timer(1.0),"timeout")
	_connect_signals()
	send_client_version()
	send_player_login_data(username)

remote func receive_version_error(server_version):
	print("you are using version " + version + ", server expected version " + server_version)
	get_tree().quit()

func send_client_version():
	rpc_id(1, "receive_client_version", version)
	
func send_player_login_data(username):
	rpc_id(1, "receive_player_login_data", username)

remote func set_names(player_login_data):
	get_node("../Map").set_names(player_login_data)

func _create_client(port, ip): # create a client connection
	peer.create_client(ip, int(port))
	get_tree().network_peer = peer

func _connect_signals(): # connect the signals to the methods
	peer.connect("connection_failed", self, "_connection_failed")
	peer.connect("connection_succeeded", self, "_connection_succeeded")

func _connection_succeeded():
	print("Connection to server succeeded")

func _connection_failed():
	print("Connection to server failed")

remote func spawn_player(peer_id):
	get_node("../Map").spawn_player(peer_id)

remote func despawn_player(peer_id):
	get_node("../Map").despawn_player(peer_id)

func send_player_state(player_state):
	rpc_unreliable_id(1, "receive_player_state", player_state)

remote func receive_world_state(world_state):
	get_node("../Map").update_world_state(world_state)

remote func receive_tilemap(tilemap_array, left, right, bot, top):
	print (tilemap_array)
	for x in range (left, right):
		for y in range (top, bot):
			#print(tilemap_array[x - left][y - top])
			get_node("../Map/TileMap").set_cell(x, y, 0, false, false, false,tilemap_array[x - left][y - top])
remote func receive_spawn_user(player_login_data):
	get_node("../Map").prepare_client()
	get_node("../Map").spawn_user()
	get_node("../Map").set_names(player_login_data)

remote func receive_allow_user():
	get_node("../Map").allow_user()

func send_tile_update(x, y, tile):
	rpc_id(1, "receive_tile_update", x, y, tile)

remote func receive_small_tile_update(x, y, tile):
	get_node("/root/Map/Player").set_tile(x, y, tile)
