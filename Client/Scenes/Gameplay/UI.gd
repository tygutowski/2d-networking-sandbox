extends CanvasLayer
var inventory_scene = preload("res://Scenes/UI/Inventory.tscn")
var hotbar_scene = preload("res://Scenes/UI/Hotbar.tscn")
var hand_scene = preload("res://Scenes/UI/Hand.tscn")

func create_inventory():
	# inventory
	var inventory = inventory_scene.instance()
	add_child(inventory)
	inventory.generate(32)
	inventory.visible = false
	
func create_hotbar():
	# hotbar
	var hotbar = hotbar_scene.instance()
	add_child(hotbar)
	hotbar.generate(8)
	hotbar.hotbar_selected(1)

func create_hand():
	# for managing what item we are dragging/dropping between inventories
	var hand = hand_scene.instance()
	add_child(hand)
