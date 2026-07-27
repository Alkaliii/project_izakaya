extends Node2D

# shows the level name in ui when you walk through it
@onready var detect = $Hurtbox2D
@export var is_exit := false
var did_entrance := false

func _ready():
	detect.detected.connect(show_level)

func show_level(s : bool,tag : Hitbox2D.tags):
	if is_exit:
		var p : PlatformerController2D = get_tree().get_first_node_in_group("player")
		Dungeon.accumulated_exp += p.exp
		Dungeon.prev_lvl = p.level
		Dungeon._load("uid://cscp8e5u6yv8o")
		return
		
		
	if s and tag == Hitbox2D.tags.PLAYER_PRESENCE:
		if did_entrance: return
		print("you entered the level!")
		Dungeon.area_entered.emit()
		did_entrance = true
