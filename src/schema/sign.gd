extends Node2D

@export var scp : ScriptPack
@export var stand_beside := true
@export var mandatory := false

@onready var detect = $Hurtbox2D
var did_man := false

func _ready():
	if mandatory:
		detect.detected.connect(player_pass)

func activate():
	if scp: 
		scp.play_scp()
		if stand_beside:
			var p : PlatformerController2D = get_tree().get_first_node_in_group("player")
			if p.global_position.x < global_position.x:
				Dungeon.move_player.emit(global_position - Vector2(16,0),global_position)
			else: 
				Dungeon.move_player.emit(global_position + Vector2(16,0),global_position)

func player_pass(s : bool,tag : Hitbox2D.tags):
	if s and tag == Hitbox2D.tags.PLAYER_PRESENCE and !did_man:
		did_man = true
		activate()
