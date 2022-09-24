extends CanvasLayer

var pressed_yet = false

func _on_Button_button_down():
	if(pressed_yet):
		pass
	else:
		pressed_yet = true
		var username = get_node("ColorRect/Username/UsernameInput").get_text() # username is whatever is in text box
		get_node("/root/Map").player_username = username
		var port = get_node("ColorRect/Port/PortInput").get_text()
		var ip = get_node("ColorRect/IP/IPInput").get_text()
		Server._connect(port, ip, username) # connect to the server
