extends Camera2D

func _physics_process(delta):
	var player_position = get_node("../Player").position
	position.x = player_position.x
	position.y = player_position.y - 30
