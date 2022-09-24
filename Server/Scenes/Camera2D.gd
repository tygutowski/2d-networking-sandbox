extends Camera2D

var velocity

func _process(delta):
	velocity = Vector2.ZERO
	if Input.is_action_pressed("ui_left"):
		velocity.x -= 1
	if Input.is_action_pressed("ui_right"):
		velocity.x += 1
	if Input.is_action_pressed("ui_up"):
		velocity.y -= 1
	if Input.is_action_pressed("ui_down"):
		velocity.y += 1
	position += velocity*50
	if Input.is_action_just_pressed("zoom_up"):
		zoom.x -= .5
		zoom.y -= .5
	if Input.is_action_just_pressed("zoom_down"):
		zoom.x += .5
		zoom.y += .5
