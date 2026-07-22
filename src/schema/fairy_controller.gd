extends CharacterBody2D


@export var player : PlatformerController2D
@export var follow_dist : float = 32

@onready var as2d = $AnimatedSprite2D

enum s {
	FOLLOW,
	STUN, #stops in place for a few seconds
	BUFF, #stops in place and sends out a heal pulse
}
var current_state : s = s.FOLLOW : 
	set(ns):
		current_state = ns
		match ns:
			s.FOLLOW: pass

func _ready():
	as2d.play("fly")
	if !player:
		await get_tree().process_frame
		player = get_tree().get_first_node_in_group("player")

var follow_pos := Vector2.ZERO
func _physics_process(delta : float):
	if player:
		#follow_pos := player.global_position + (Vector2.UP * 16.0)
		#if player.playerSprite.flip_h: follow_pos = follow_pos.lerp(player.global_position + (Vector2(-1.0,1.0) * -16.0),8.0 * delta)
		#else: follow_pos = follow_pos.lerp(player.global_position + (Vector2.ONE * -16.0),8.0 * delta)
		set_follow_pos(delta)
		var follow_spd_mod := clampf((global_position - player.global_position).length() / follow_dist,0.0,1.0)
		if should_follow():
			global_position = global_position.lerp(follow_pos,1.0 * delta)
		elif current_state == s.FOLLOW: global_position = global_position.lerp(follow_pos,follow_spd_mod * delta)
		
		as2d.flip_h = global_position.x > player.global_position.x

func set_follow_pos(delta : float):
	var new_follow_pos : Vector2 = Vector2.ZERO
	if player.playerSprite.flip_h: new_follow_pos.x = 16.0 #follow_pos.lerp(player.global_position + (Vector2(-1.0,1.0) * -16.0),8.0 * delta)
	else: new_follow_pos.x = -16.0
	if player.is_on_floor(): new_follow_pos.y = -16.0
	else: new_follow_pos.y = 16.0
	
	follow_pos = follow_pos.lerp(new_follow_pos + player.global_position,8.0*delta)

func should_follow() -> bool:
	var in_state := current_state == s.FOLLOW
	var out_of_range := (global_position - player.global_position).length() > follow_dist
	return in_state and out_of_range













#
