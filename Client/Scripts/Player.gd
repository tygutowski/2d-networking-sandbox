extends KinematicBody2D

export (int) var gravity = 1200
export (int) var jump_speed = -400
export (int) var speed = 100
var blue_dino = preload("res://Resources/bluedino.tres")
var red_dino = preload("res://Resources/reddino.tres")
var yellow_dino = preload("res://Resources/yellowdino.tres")
var green_dino = preload("res://Resources/greendino.tres")
var player_state
var running = false
var run_multiplier = 2.0
var velocity = Vector2.ZERO
var player_color = "blue"
var player_interaction_range = 0
var player_tool_range = 0
var mouse_cell
var mouse_position
var mouse_local_position
var mouse_local_cell
var mouse_cell_id
var mouse_distance
var connected_to_server = false
var mouse_left_down = false
var mouse_right_down = false
var tile_in_hand 
var inventory_opening = true
onready var tilemap_node = get_node("/root/Map/TileMap")
onready var ui = get_node("/root/Map/UI")
onready var inventory = get_node("/root/Map/UI/Inventory")
onready var hotbar = get_node("/root/Map/UI/Hotbar")
var held_item_id
var held_item_name
var held_item_type
var held_item_subtype
var held_item_tile_id

func get_held_item_data():
	var slot_num = hotbar.slot_number
	var held_item = hotbar.get_node("PanelContainer/CenterContainer/Grid/T" + str(slot_num))
	held_item_id = held_item.get_item_id()
	held_item_name = held_item.get_item_name()
	held_item_type = held_item.get_item_type()
	held_item_subtype = held_item.get_item_subtype()
	if(held_item_type == "tile"):
		held_item_tile_id = held_item.get_item_tile_id()
	else:
		held_item_tile_id = null

func set_username(username):
	get_node("RichTextLabel").bbcode_text = "[center]" + str(username) + "[/center]"

func _ready():
	finished_connecting()
#	set_item_held("")
#	item_in_hand_node = gui.get_node("Inventory/Grid/" + str(item_in_hand))

func finished_connecting():
	# player spawns far in the air, so raycast down to spawn them on the ground instead
	get_node("RayCast2D").enabled = true
	get_node("RayCast2D").set_cast_to(Vector2(0,1))
	position.y = get_node("RayCast2D").get_collision_point().y - 10
	connected_to_server = true

func _input(event): # get player input
	velocity.x = 0
	movement_input() # movement (WASD, Jump, Run)
	keyboard_input() # toolbar, buttons
	mouse_input(event) # mouse position
	animation_input() # animations
	hotbar_selection_input(event)

func mouse_input(event):
	# on input (press OR release)
	if event is InputEventMouseButton:
		mouse_left_down = false
		mouse_right_down = false
		# while LMB is held down
		if event.is_action_pressed("left_mouse") and event.is_pressed():
			mouse_left_down = true
			get_held_item_data()
		elif event.is_action_pressed("left_mouse") and not event.is_pressed():
			mouse_left_down = false
		# while RMB is held down
		if event.is_action_pressed("right_mouse") and event.is_pressed():
			mouse_right_down = true
			get_held_item_data()
		elif event.is_action_pressed("right_mouse") and not event.is_pressed():
			mouse_right_down = false

func keyboard_input():
	if Input.is_action_just_pressed("ui_reset"):
		respawn()
	elif Input.is_action_just_pressed("ui_escape"):
		toggle_inventory()

func hotbar_selection_input(event):
	if event is InputEventMouseButton:
		if event.is_pressed():
			# scroll up
			if event.button_index == BUTTON_WHEEL_DOWN:
				hotbar.hotbar_increase()
				get_held_item_data()
			if event.button_index == BUTTON_WHEEL_UP:
				hotbar.hotbar_decrease()
				get_held_item_data()
	if Input.is_action_just_pressed("1"):
		hotbar.hotbar_selected(1)
		get_held_item_data()
	elif Input.is_action_just_pressed("2"):
		hotbar.hotbar_selected(2)
		get_held_item_data()
	elif Input.is_action_just_pressed("3"):
		hotbar.hotbar_selected(3)
		get_held_item_data()
	elif Input.is_action_just_pressed("4"):
		hotbar.hotbar_selected(4)
		get_held_item_data()
	elif Input.is_action_just_pressed("5"):
		hotbar.hotbar_selected(5)
		get_held_item_data()
	elif Input.is_action_just_pressed("6"):
		hotbar.hotbar_selected(6)
		get_held_item_data()
	elif Input.is_action_just_pressed("7"):
		hotbar.hotbar_selected(7)
		get_held_item_data()
	elif Input.is_action_just_pressed("8"):
		hotbar.hotbar_selected(8)
		get_held_item_data()

# animation
func animation_input():
	if($AnimatedSprite.get_speed_scale() != 1):  # set speed scale to 1 if it isnt 1
		$AnimatedSprite.set_speed_scale(1)
	if Input.is_action_pressed("ui_right") or Input.is_action_pressed("ui_left"):
		if Input.is_action_pressed("ui_run"): # if running
			$AnimatedSprite.set_speed_scale(2) # set speed to 2
			$AnimatedSprite.play("run") # play run
		else:
			$AnimatedSprite.play("walk") # otherwise walk
	else: # if not moving, play idle
		$AnimatedSprite.play("idle")

func movement_input():
	# walk left
	if Input.is_action_pressed("ui_left"):
		# flip sprite left
		$AnimatedSprite.set_flip_h(true) 
		velocity.x = -speed
	# walk right
	elif Input.is_action_pressed("ui_right"):
		# flip sprite right
		$AnimatedSprite.set_flip_h(false)
		velocity.x = speed
	# run
	if Input.is_action_pressed("ui_run"):
		velocity.x *= run_multiplier
	# jump
	if Input.is_action_just_pressed("ui_select"):
		#if is_on_floor():
		velocity.y = jump_speed

func break_block():
	server_set_tile(mouse_cell.x, mouse_cell.y, "Air")
	# drop item on ground


func place_block():
	# if tile is available
	var held_block = held_item_name
	server_set_tile(mouse_cell.x, mouse_cell.y, held_block)
	# play placement sound


func subtract_item(num):
	pass

func manage_mouse():
	if(connected_to_server): # if player is connected to server (not in title screen)
		mouse_position = get_global_mouse_position() # where mouse is globally
		mouse_cell = tilemap_node.world_to_map(mouse_position) # which cell mouse is in
		mouse_local_position = position - mouse_position # where mouse is locally
		mouse_cell_id = tilemap_node.get_cellv((tilemap_node).world_to_map(mouse_position)) # id of cell mouse is in
		mouse_distance = mouse_position.distance_to(position) # how far distance is to player

func clear_hand(): # item has run out or has been consumed
	get_node("/root/Map/CanvasLayer/GUI").held_item = null
	get_node("/root/Map/Player").set_item_held(get_parent().name.trim_prefix("ItemSlot"))
	queue_free()

func _process(_delta):
	if(inventory_opening):
		manage_mouse()
		if mouse_left_down:
			print("LMBDOWN")
			if held_item_type == "tile":
				place_block()
			if held_item_type == "weapon":
				if held_item_subtype == "ranged":
					shoot_weapon()
				elif held_item_subtype == "melee":
					swing_weapon()
			elif held_item_type == "tool":
				swing_weapon()
			elif held_item_type == "armor":
				try_equip_armor()
			elif held_item_type == "trinket":
				try_equip_trinket()
			elif held_item_type == "consumable":
				consume()

func shoot_weapon():
	print("shoot")
	pass
func swing_weapon():
	break_block()
	#print("swing")
	pass
func use_tool():
	print("dig")
	pass
func try_equip_armor():
	print("equip")
	pass
func try_equip_trinket():
	print("equip")
	pass
func consume():
	print("consume")
	pass

func _physics_process(delta): # moves the player each frame (60fps)
	movement(delta)
	get_player_state()

func respawn():
	position = Vector2.ZERO
	get_held_item_data()

# move the player
func movement(delta): 
	velocity.y += gravity * delta
	# cap downwards velocity
	if velocity.y > 1200: 
		velocity.y = 1200
	velocity = move_and_slide(velocity, Vector2.UP)

# get the player state (position, time, color, animation, direction)
func get_player_state(): 
	player_state = {"T": OS.get_system_time_msecs(), "P": get_global_position(), "C": player_color, "A": $AnimatedSprite.get_animation(), "D":$AnimatedSprite.is_flipped_h()}
	Server.send_player_state(player_state)

# open or close the inventory
func toggle_inventory():
	#if inventory opening
	if inventory_opening: 
		# inventory is visible
		ui.get_node("Inventory").visible = true 
		# inventory will close next time (toggle)
		inventory_opening = false 
	#if inventory closing
	else: 
		# inventory is not visible
		ui.get_node("Inventory").visible = false 
		# inventory will open next time (toggle)
		inventory_opening = true 
		get_held_item_data()

func server_set_tile(x, y, tile):
	Server.send_tile_update(x, y, tile)

func set_tile(x, y, tile):
	tilemap_node.set_cell(x, y, 0, false, false, false, tilemap_node.get_tile_atlas_coordinates(tile))
