extends Node2D

# shows the level name in ui when you walk through it
@onready var detect = $Hurtbox2D


func _ready():
	detect.detected.connect(show_level)

func show_level(s : bool,tag : Hitbox2D.tags):
	if s and tag == Hitbox2D.tags.PLAYER_PRESENCE:
		print("you entered the level!")
	pass
