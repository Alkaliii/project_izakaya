extends Node


@export var player_controller : PlatformerController2D
@export var attack_box : Hitbox2D
@export var detect_box : Hurtbox2D

func _ready():
	player_controller.add_to_group("player")

func _process(delta):
	if attack_box: attack_box.position.x = -16.0 if player_controller.playerSprite.flip_h else 16.0
