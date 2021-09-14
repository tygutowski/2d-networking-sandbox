extends KinematicBody2D

var blue_dino = preload("res://Resources/bluedino.tres")
var red_dino = preload("res://Resources/reddino.tres")
var yellow_dino = preload("res://Resources/yellowdino.tres")
var green_dino = preload("res://Resources/greendino.tres")

func _ready():
	set_player_color("blue")
	set_animation("idle")

func despawn():
	queue_free()

func move_player(new_position): # move player given a position
	set_position(new_position)

func set_direction(direction):
	$AnimatedSprite.set_flip_h(direction)

func set_player_color(player_color):
	match player_color:
		"":
			$AnimatedSprite.set_sprite_frames(blue_dino)
		"blue":
			$AnimatedSprite.set_sprite_frames(blue_dino)
		"red":
			$AnimatedSprite.set_sprite_frames(red_dino)
		"yellow":
			$AnimatedSprite.set_sprite_frames(yellow_dino)
		"green":
			$AnimatedSprite.set_sprite_frames(green_dino)
		_:
			$AnimatedSprite.set_sprite_frames(blue_dino)

func set_animation(current_animation):
	$AnimatedSprite.play(current_animation)
