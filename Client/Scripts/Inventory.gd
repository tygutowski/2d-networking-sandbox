extends Control

var slot_template = preload("res://Scenes/Templates/InventorySlot.tscn")
onready var grid = get_node("PanelContainer/CenterContainer/Grid")

func generate(size):
	for item in range(1, size + 1): # for each slot in the inventory data list
		var item_id = "I" + str(item)
		var slot_new = slot_template.instance() # make a new slot
		slot_new.name = item_id
		# if the slot has an item
		if PlayerData.inv_data[item_id]["Item"] != null:
			# set the name and icon
			var true_type = ItemData.item_data[str(PlayerData.inv_data[item_id]["Item"])]["type"]
			var type_list = true_type.split(":")
			var type = type_list[0]
			var name = ItemData.item_data[str(PlayerData.inv_data[item_id]["Item"])]["name"]
			var icon_texture
			if(type == "tile"):
				icon_texture = load("res://Sprites/spritesheet.png")
				var id = TileData.tile_data[name]["tile id"]
				
			else:
				icon_texture = load("res://Sprites/" + name + ".png")
				

			slot_new.get_node("IconTexture").set_texture(icon_texture)
			slot_new.set_item_data(PlayerData.inv_data[item_id]["Item"])
		# set the quantity
		var quantity = PlayerData.inv_data[item_id]["Quantity"]
		if quantity != null:
			slot_new.get_node("QuantityLabel").set_text(str(quantity))
			if quantity == 1:
				slot_new.get_node("QuantityLabel").visible = false
		else:
			slot_new.get_node("QuantityLabel").visible = false
		grid.add_child(slot_new, true)
