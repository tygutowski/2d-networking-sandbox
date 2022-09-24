#extends Resource
#class_name Item
#
## imported from .json
#var number_of_items
#var id
#var name
#var type
#var description
#var max_stack
#var texture
#var drops
#var durability
#var attack_damage
#var magic_damage
#var hardness
#var shoot_to_break
#var shoot_to_break_hardness
#
## reported in game
#var quantity
##signal quantity_changed
#
#func _ready():
#	id = int(ImportData.item_data[str(id)]["ID"]) # int
#	var id_string = str(id)
#	number_of_items = ImportData.item_data.size() # int
#	name = ImportData.item_data[id_string]["Name"] # string
#	type = ImportData.item_data[id_string]["Type"] # string
#	description  = ImportData.item_data[id_string]["Description"] # string
#	max_stack= int(ImportData.item_data[id_string]["MaxStack"]) # int
#	texture = ImportData.item_data[id_string]["Texture"] + ".png" # string
#	drops = int(ImportData.item_data[id_string]["Drops"]) # int (ID of item)
#	durability = int(ImportData.item_data[id_string]["Durability"]) # int
#	attack_damage = int(ImportData.item_data[id_string]["AttackDamage"]) # int
#	magic_damage = int(ImportData.item_data[id_string]["MagicDamage"]) # int
#	hardness = int(ImportData.item_data[id_string]["Hardness"]) # int
#	shoot_to_break = bool(ImportData.item_data[id_string]["ShootToBreak"]) # boolean
#	shoot_to_break_hardness = int(ImportData.item_data[id_string]["ShootToBreakHardness"]) # int
#	quantity = randi() % max_stack + 1
