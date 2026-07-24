@tool
extends Area2D
class_name Hitbox2D

# I make Hurtbox2D react!

enum tags {
	GENERIC,
	PLAYER,
	ENEMY,
	INTERACTION,
	LADDER,
}

@export var box_tag : tags = tags.GENERIC

func _init():
	set_collision_layer_value(1,false)
	set_collision_layer_value(6,true)
	set_collision_mask_value(1,false)
	set_collision_mask_value(7,true)
