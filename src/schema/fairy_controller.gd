extends CharacterBody2D


@export var player : PlatformerController2D
@export var follow_dist : float = 32

@onready var as2d : AnimatedSprite2D = $AnimatedSprite2D
@onready var fairy_detect : Hurtbox2D = $FairyDetect

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
	fairy_detect.detected.connect(on_detect)
	if !player:
		await get_tree().process_frame
		player = get_tree().get_first_node_in_group("player")

var restore_mod := 1.0
func on_detect(state: bool,t : Hitbox2D.tags):
	if t == Hitbox2D.tags.PLAYER and state and current_state != s.STUN:
		#print("STUNNED")
		current_state = s.STUN
		as2d.play("hurt")
		var knockback := (global_position - player.global_position) * 10.0
		knockback.y = knockback.y / 3.0
		velocity = knockback
		await get_tree().create_timer(0.1).timeout
		velocity /= 4.0;
		await get_tree().create_timer(1.0).timeout
		as2d.play("buff")
		await as2d.animation_finished
		as2d.play("fly")
		restore_mod = 0.0
		current_state = s.FOLLOW

var follow_pos := Vector2.ZERO
func _physics_process(delta : float):
	if player:
		#follow_pos := player.global_position + (Vector2.UP * 16.0)
		#if player.playerSprite.flip_h: follow_pos = follow_pos.lerp(player.global_position + (Vector2(-1.0,1.0) * -16.0),8.0 * delta)
		#else: follow_pos = follow_pos.lerp(player.global_position + (Vector2.ONE * -16.0),8.0 * delta)
		set_follow_pos(delta)
		var follow_spd_mod := clampf((global_position - player.global_position).length() / follow_dist,0.0,1.0) * restore_mod
		if should_follow():
			restore_mod = lerpf(restore_mod,1.0,0.5 * delta)
			global_position = global_position.lerp(follow_pos,1.0 * restore_mod * delta)
		elif current_state == s.FOLLOW: global_position = global_position.lerp(follow_pos,follow_spd_mod * delta)
		
		as2d.flip_h = global_position.x > player.global_position.x
	velocity = lerp(velocity,Vector2.ZERO,0.5 * delta)
	move_and_slide()
	#global_position = global_position.round()

func set_follow_pos(delta : float):
	var new_follow_pos : Vector2 = Vector2.ZERO
	if player.playerSprite.flip_h: new_follow_pos.x = 16.0 #follow_pos.lerp(player.global_position + (Vector2(-1.0,1.0) * -16.0),8.0 * delta)
	else: new_follow_pos.x = -16.0
	if player.is_on_floor(): new_follow_pos.y = -12.0
	else: new_follow_pos.y = 12.0
	
	follow_pos = follow_pos.lerp(new_follow_pos + player.global_position,8.0*delta)

func should_follow() -> bool:
	var in_state := current_state == s.FOLLOW
	var out_of_range := (global_position - player.global_position).length() > follow_dist
	return in_state and out_of_range













#
