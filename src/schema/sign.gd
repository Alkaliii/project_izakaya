extends Node2D
class_name Sign2D

@export var scp : ScriptPack
@export var stand_beside := true
@export var sb_dist := 16.0
@export var sb_height := 0.0
@export var mandatory := false
@export var one_shot := false

@onready var detect = $Hurtbox2D
@onready var interacta = $Hitbox2D
var did_man := false

func _ready():
	if mandatory:
		detect.detected.connect(player_pass)
	_after_ready()

func _after_ready(): pass

func activate():
	if scp: 
		scp.play_scp()
		if stand_beside:
			var p : PlatformerController2D = get_tree().get_first_node_in_group("player")
			if p.global_position.x < global_position.x:
				Dungeon.move_player.emit(global_position - Vector2(sb_dist,-sb_height),global_position)
			else: 
				Dungeon.move_player.emit(global_position + Vector2(sb_dist,sb_height),global_position)
	if one_shot:
		detect.queue_free()
		interacta.queue_free()

func player_pass(s : bool,tag : Hitbox2D.tags):
	if s and tag == Hitbox2D.tags.PLAYER_PRESENCE and !did_man:
		did_man = true
		activate()
