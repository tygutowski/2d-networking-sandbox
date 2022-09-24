extends Node


var world_state = {}

func _physics_process(_delta):
	if not get_parent().player_state_collection.empty(): # if the player collection state has entries
		world_state = get_parent().player_state_collection.duplicate(true) # deep duplicate
		for peer in world_state.keys(): # for each peer
			world_state[peer].erase("T") # remove time (it doesnt matter at this point)
			
		world_state["T"] = OS.get_system_time_msecs() # set new time (to send back)
		get_parent().send_world_state(world_state) # send the world state off
