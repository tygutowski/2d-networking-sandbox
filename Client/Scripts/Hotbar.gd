extends Control

var slot_template = preload("res://Scenes/Templates/InventorySlot.tscn")
var selected_stylebox = preload("res://Resources/selected_stylebox.tres")
var default_stylebox = preload("res://Resources/default_stylebox.tres")
onready var grid = get_node("PanelContainer/CenterContainer/Grid")
var slot_number = 1

func hotbar_selected(slot): # style selected/default
	var slot_name = "T" + str(slot)
	var selected_slot = grid.get_node(slot_name)
	for slots in range(1,9):
		grid.get_node("T" + str(slots)).add_stylebox_override('panel', default_stylebox)
	selected_slot.add_stylebox_override('panel', selected_stylebox)
	slot_number = slot

func hotbar_increase():
	slot_number += 1
	if(slot_number > 8):
		slot_number = 1
	hotbar_selected(slot_number)

func hotbar_decrease():
	slot_number -= 1
	if(slot_number < 1):
		slot_number = 8
	hotbar_selected(slot_number)

func generate(size):
	for item in range(1, size + 1): # for each slot in the inventory data list
		var item_id = "T" + str(item)
		var slot_new = slot_template.instance() # make a new slot
		slot_new.name = item_id
		# if the slot has an item
		if PlayerData.inv_data[item_id]["Item"] != null:
			# set the name and icon
			var name = ItemData.item_data[str(PlayerData.inv_data[item_id]["Item"])]["name"]
			var icon_texture = load("res://Sprites/" + name + ".png")
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

