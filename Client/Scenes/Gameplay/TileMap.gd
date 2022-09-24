#tool
extends TileMap

export (int) var counter = 0
export (bool) var generate_autotile_collision = false

var tile_size = 16
var sprite_sheet_size = Vector2(16, 16)

func _ready():
	if Engine.editor_hint:
		_generate_autotile_collision()

func _generate_autotile_collision():
	for x in sprite_sheet_size.x:
		for y in sprite_sheet_size.y:
			if(x == 1 && y == 1):
				pass
			else:
				var shape = ConvexPolygonShape2D.new()
				shape.points = [Vector2(0,0), Vector2(0, tile_size), Vector2(tile_size, tile_size), Vector2(tile_size, 0)]
				tile_set.tile_add_shape(0, shape, Transform2D(0.0, Vector2(0,0)), false, Vector2(x,y))

func get_tile_id(block_name):
	return int(TileData.tile_data[block_name]["tile id"])

func get_item_id(block_name):
	return int(TileData.tile_data[block_name]["item id"])

func get_tile_atlas_coordinates(block_name):
	var tile_id = int(TileData.tile_data[block_name]["tile id"])
	var x = tile_id%16
	var y = int(tile_id/16)
	return(Vector2(x,y))
