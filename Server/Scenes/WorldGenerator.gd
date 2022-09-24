extends Node

var network = NetworkedMultiplayerENet.new()
var port = 25565
var max_players = 10
export (int) var worldStart = -150
export (int) var worldEnd = 150
export (int) var worldDepth = 50
export (int) var skyLimit = -50
export (int) var stoneDepth = 30
export (int) var stoneVariance = 5
export (int) var caveDepth = 20
export (int) var heightMultiplier = 20
export (int) var heightAddition = 0
export (float) var caveNoise = .05
export (Script) var saveGameClass
export (int) var seed_number = 0

var worldTileMap
var surfaceLow
var surfaceHeight
var saveVariables = ["playerPosition", "tileMapCells"]
var horizon = 0
var noise = OpenSimplexNoise.new()
var ore_noise = OpenSimplexNoise.new()
var rng = RandomNumberGenerator.new()
var selectedTile
var world_seed
var worldSize
var worldHeight
var player_state_collection = {}
var tilemap_array = []
var offset_factor = 0
var offset_counter = 0

func setup_world_generation(seed_num): #Initialization
	seed_number = int(seed_num)
	worldSize = worldEnd - worldStart
	worldHeight = skyLimit - worldDepth
	surfaceLow = skyLimit # change later if i need
	offset_factor = worldSize * 2
	GenerateWorld()

func GenerateWorld(): #World Generation
	LoadNoise()
	LoadOreNoise()
	GenerateStone()
	GenerateOres()
	GenerateTerrain()
	GenerateLayerMix()
	GenerateCaves()
	
	print("generation complete")

func LoadNoise(): #Generates perlin noise for world generation
	noise.octaves = 4
	noise.period = 50.0
	noise.persistence = 0.8
	randomize()
	if(seed_number == 0):
		noise.set_seed(randi())
	else:
		noise.set_seed(seed_number)
	world_seed = noise.seed

func LoadOreNoise():
	ore_noise.octaves = 5
	ore_noise.period = 50.0
	ore_noise.persistence = 0.9
	ore_noise.set_seed(world_seed)

func GenerateStone(): #Generates all of the stone in the world
	for x in range(worldStart,worldEnd):
		for y in range(stoneDepth,worldDepth):
			set_tile(x,y,"Stone")

func GenerateOres():
	for tile in TileData.tile_data:
		var is_ore = TileData.tile_data[tile]["is ore"]
		if(is_ore == true):
			var ore_name = tile
			var weight = int(TileData.tile_data[tile]["weight"])
			var vein_max_size = int(TileData.tile_data[tile]["vein max size"])
			var start_depth = int(TileData.tile_data[tile]["start depth"])
			var stop_depth = int(TileData.tile_data[tile]["stop depth"])
			GenerateOre(ore_name, weight, vein_max_size, start_depth, stop_depth)

func GenerateOre(ore_name, weight, vein_max_size, start_depth, stop_depth):
	var tempNoise
	var end_range
	if(stop_depth == -1):
		end_range = worldDepth
	else:
		end_range = surfaceLow + caveDepth + start_depth + stop_depth

	for x in range(worldStart, worldEnd):
		for y in range(caveDepth+start_depth, end_range):
			var random_number = rng.randf_range(0,500)
			if(weight > random_number):
				create_vein(x, y, ore_name, vein_max_size)

func create_vein(x, y, ore_name, vein_max_size):
	set_tile(x, y, ore_name)
	var direction = rng.randi_range(0,1)
	if(direction == 0): # right
		for i in range(vein_max_size):
			var walker_direction = rng.randi_range(0,3)
			if(walker_direction == 0):
				x += 1
			if(walker_direction == 1):
				x -= 1
			if(walker_direction == 2):
				y += 1
			if(walker_direction == 3):
				y -= 1
			set_tile(x, y, ore_name)

func GenerateTerrain(): #Uses perlin noise to generate world
	print("seed is: " + str(noise.seed))
	surfaceLow = skyLimit
	for x in range(worldStart,worldEnd): #Generates grass
		surfaceHeight = noise.get_noise_2d(horizon,x) * heightMultiplier - heightAddition
		#surfaceShift = noise.get_noise_2d(horizon,y) * heightMultiplier - heightAddition
		if(surfaceLow < surfaceHeight):
			surfaceLow = surfaceHeight		
		for y in range(surfaceHeight-1,skyLimit,-1): #Deletes blocks above grass
			set_tile(x,y,"Air")
		for y in range(surfaceHeight+1,stoneDepth): #Generates dirt below grass
			set_tile(x,y,"Dirt")
		# generates grass
		set_tile(x, surfaceHeight, "Grass")

func GenerateCaves(): #Uses 2d perlin noise to generate caves
	var tempNoise
	for x in range(worldStart,worldEnd):
		for y in range(surfaceLow+caveDepth, worldDepth):
			tempNoise = noise.get_noise_2d(x,y)
			if(tempNoise>caveNoise):
				set_tile(x,y,"Air")

func GenerateLayerMix(): #Mixes the stone and dirt together
	var randomNumber
	for x in range (worldStart,worldEnd):
		for y in range (stoneDepth, stoneDepth+stoneVariance/2):
			randomNumber = rng.randf_range(0,100)
			if(randomNumber>25):
				set_tile(x,y,"Dirt")
		for y in range (stoneDepth, stoneDepth+stoneVariance):
			randomNumber = rng.randf_range(0,100)
			if(randomNumber>50):
				set_tile(x,y,"Dirt")

func get_tilemap():
	tilemap_array = []
	for x in range(worldStart, worldEnd):
		tilemap_array.append([])
		for y in range (skyLimit, worldDepth):
			tilemap_array[x - worldStart].append($TileMap.get_cell_autotile_coord(x, y))
	print("tilemap collected")
	return tilemap_array

#remote func SendWorldState(world_state):
#	rpc_unreliable_id(0, "RecieveWorldState", world_state)

func receive_tile_update(x, y, tile):
	print("tile update processed")
	set_tile(x, y, tile)

func set_tile(x, y, tile):
	get_node("/root/Server").send_small_tile_update(x, y, tile)
	$TileMap.set_cell(x, y, 0, false, false, false, $TileMap.get_tile_atlas_coordinates(tile))
