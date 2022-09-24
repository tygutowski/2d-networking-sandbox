extends Node

# preload all packed scenes
var player_spawn = preload("res://Scenes/Templates/PlayerTemplate.tscn")
var user_spawn = preload("res://Scenes/Gameplay/Player.tscn")
onready var ui = get_node("UI")

var player_username
var previous_world_state = 0
var world_state_buffer = []
var player_data = {}
var private_player_login_data = {}

const interpolation_offset = 25 # TEST WITH THIS TEST WITH THIS TEST WITH THIS TEST WITH THIS TEST WITH THIS TEST WITH THIS TEST WITH THIS TEST WITH THIS TEST WITH THIS TEST WITH THIS TEST WITH THIS TEST WITH THIS TEST WITH THIS TEST WITH THIS TEST WITH THIS TEST WITH THIS TEST WITH THIS TEST WITH THIS TEST WITH THIS TEST WITH THIS TEST WITH THIS TEST WITH THIS TEST WITH THIS TEST WITH THIS TEST WITH THIS TEST WITH THIS TEST WITH THIS TEST WITH THIS TEST WITH THIS TEST WITH THIS TEST WITH THIS TEST WITH THIS TEST WITH THIS TEST WITH THIS TEST WITH THIS TEST WITH THIS TEST WITH THIS TEST WITH THIS TEST WITH THIS TEST WITH THIS TEST WITH THIS TEST WITH THIS TEST WITH THIS TEST WITH THIS

# runs at 60fps forced
func _physics_process(_delta):
	buffer_world_state()

# set all player names upon connection
func set_names(player_name_data):
	for player in player_name_data:
		if has_node(str(player)):
			var username = "[center]" + str(player_name_data[player]) + "[/center]"
			get_node(str(player)).get_node("RichTextLabel").bbcode_text = username

func spawn_player(peer_id): # spawn a player at a position given its peer_id
	if(get_tree().get_network_unique_id() == peer_id): # if the peer_id is the player, then ignore
		player_data[peer_id] = {"A": "idle", "C": "blue", "D": false} # what the player spawns in as (FOR THEMSELF)
	else: # if the peer id is another player
		player_data[peer_id] = {"A": "idle", "C": "blue", "D": false} # what other players spawn in as (FOR EVERYONE ELSE)
		var new_player = player_spawn.instance() # create an instance of the player template
		new_player.name = str(peer_id) # set the name to its peer_id
		add_child(new_player) # and add it as a child to the map

# buffer the world state so the player moves smoothly
func buffer_world_state(): 
	var render_time = OS.get_system_time_msecs() - interpolation_offset
	if world_state_buffer.size() > 1:
		while world_state_buffer.size() > 2 and render_time > world_state_buffer[1].T:
			world_state_buffer.remove(0)
		var interpolation_factor = float(render_time - world_state_buffer[0]["T"]) / float(world_state_buffer[1]["T"] - world_state_buffer[0]["T"])
		for peer in world_state_buffer[1].keys():
			if str(peer) == "T":
				continue
			if peer == get_tree().get_network_unique_id(): # if peer is player
				continue
			if not world_state_buffer[0].has(peer): # if the buffer doesnt have the player
				continue
			if has_node(str(peer)): # if the peer already exists, interpolate its position
				var new_position = lerp(world_state_buffer[0][peer]["P"], world_state_buffer[1][peer]["P"], interpolation_factor)
				get_node(str(peer)).move_player(new_position)
			else: # if the peer does not exist, spawn it (this is used for previously connected players to load in)
				spawn_player(peer)

#despawn a player given its peer_id
func despawn_player(peer_id):
	# delete the peer ID from the world state buffer
	for peer in world_state_buffer.size():
		world_state_buffer[peer].erase(peer_id)
	# delete the peer ID from player data
	player_data.erase(peer_id)
	# if the player exists, delete the player
	if(has_node(str(peer_id))):
		get_node(str(peer_id)).queue_free()

# update the world state
func update_world_state(world_state):
	# if the new world state is newer than the old world state
	if(world_state["T"] > previous_world_state):
		# the old world state is now the new world state
		previous_world_state = world_state["T"] 
		# add the newest world state to the buffer
		world_state_buffer.append(world_state) 
	update_player_state(world_state)
	
# every time a new playerstate is received
func update_player_state(world_state):
	# make a deep duplicate of the playerstate file
	var world_state_temp = world_state.duplicate(true)
	for peer in world_state_temp: # for every player in the world_state_temp
		if player_data.has(peer): # if the player is in player_data 
			if has_node(str(peer)): # if the player has a node connected with their name
				if player_data[peer]["A"] != world_state_temp[peer]["A"]:
					player_data[peer]["A"] = world_state_temp[peer]["A"]
					get_node(str(peer)).set_animation(player_data[peer]["A"])
				if player_data[peer]["C"] != world_state_temp[peer]["C"]:
					player_data[peer]["C"] = world_state_temp[peer]["C"]
					get_node(str(peer)).set_player_color(player_data[peer]["C"])
				if player_data[peer]["D"] != world_state_temp[peer]["D"]:
					player_data[peer]["D"] = world_state_temp[peer]["D"]
					get_node(str(peer)).set_direction(player_data[peer]["D"])


func prepare_client():
	# instance the screen elements
	ui.create_inventory()
	ui.create_hotbar()
	ui.create_hand()

func spawn_user():
	var player = user_spawn.instance()
	player.set_process(false)
	add_child(player)
	

func allow_user():
	# set player name
	get_node("/root/Map/Player/RichTextLabel").bbcode_text = "[center]" + str(player_username) + "[/center]"
	# show the tilemap (which has already loaded)
	get_node("TileMap").visible = true
	# show the background
	get_node("Background").visible = true
	# load player	
	get_node("Player").set_process(true)
	# delete the title screen
	get_node("UI/TitleScreen").queue_free()
