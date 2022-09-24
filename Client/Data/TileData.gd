extends Node

var tile_data = {}

func _ready():
	var tile_data_file = File.new()
	tile_data_file.open("res://Data/TileData.json", File.READ)
	var tile_data_json = JSON.parse(tile_data_file.get_as_text())
	tile_data_file.close()
	tile_data = tile_data_json.result
