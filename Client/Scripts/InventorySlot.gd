extends PanelContainer

var item_id
var type
var subtype
var item_name
var tile_id

func set_item_data(new_id):
	item_id = new_id
	var id_str= str(item_id)
	item_name = ItemData.item_data[id_str]["name"]
	var true_type = ItemData.item_data[id_str]["type"]
	var type_list = true_type.split(":")
	type = type_list[0]
	if type_list.size() == 2:
		subtype = type_list[1]
	else:
		subtype = null
	if(type == "tile"):
		tile_id = TileData.tile_data[item_name]["tile id"]

func get_item_id():
	return item_id

func get_tile_id():
	return tile_id

func get_item_type():
	return type

func get_item_subtype():
	return subtype

func get_item_name():
	return item_name
	
func get_item_tile_id():
	return tile_id
