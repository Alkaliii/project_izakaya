extends CharacterBody2D


enum t {
	STILL, #this enemy doesn't move
	CHASE, #this enemy tries to move to the player when the player gets close
	PATROL, # this enemy moves around a specific patrol point
}

enum state {
	OKAY, #do movement
	STUN, #stop movement
	DEAD, #stop movement, despawn, reward exp
}

@export var enemy_movement : t = t.STILL
@export var is_flying := false # this enemy is placed in front of the arena, won't collide with obstacles, and can navigate in all four directions
@export_group("Attributes")
@export_range(0,3,1) var max_health : int = 1
@export var bonus_health : int = 0 #so a boss isn't weak as shit and stronger enemies and stronger player works
@export var contact_damage := true #if this enemy attacks in a special way disable this
@export var movement_speed := 1.0 #48 px per second for grounded enemies, linear interp 1.0 * delta

@export_group("Simple Special Attack")
@export var hurtboxes : Array[Hurtbox2D] = []
@export var timer_threshold : float = 2.5
@export var timer_cooldown : float = 2.5

@onready var as3d : AnimatedSprite2D = $AnimatedSprite2D
@onready var cdbx : Hitbox2D = $ContactDamage
@onready var damage_detect : Hurtbox2D = $DamageDetect


const MOVE_SPEED := 48.0
var current_state : state = state.OKAY
var current_health := 3 :
	set(nv):
		current_health = max(nv,0)

var patrol_point := Vector2.ZERO
func _ready():
	patrol_point = global_position
	current_health = max_health + bonus_health
	if cdbx: for c in cdbx.get_children():
		if c is CollisionPolygon2D: c.set_deferred("disabled",!contact_damage)
		elif c is CollisionShape2D: c.set_deferred("disabled",!contact_damage)
	if damage_detect: damage_detect.detected.connect(on_detect)
	if as3d.sprite_frames.has_animation("idle"): as3d.play("idle")

#const min_detect_dist := 20
func on_detect(s : bool,tag : Hitbox2D.tags):
	var player : PlatformerController2D = get_tree().get_first_node_in_group("player")
	if tag == Hitbox2D.tags.PLAYER and s and current_state != state.STUN:
		if player.health > 2: return
		#if player and (global_position - player.global_position).length() > min_detect_dist: return
		current_state = state.STUN
		if player: as3d.flip_h = global_position.x > player.global_position.x
		current_health -= 1
		do_knock = true
		as3d.material.set_shader_parameter("hit",true)
		if as3d.sprite_frames.has_animation("hurt"): 
			as3d.play("hurt")
			await as3d.animation_finished
		else: 
			await get_tree().create_timer(0.5).timeout
		as3d.material.set_shader_parameter("hit",false)
		
		if current_health != 0:
			if as3d.sprite_frames.has_animation("idle"): as3d.play("idle")
			current_state = state.OKAY
		else:
			current_state = state.DEAD
			var tw := create_tween()
			#tw.tween_property(as3d.material,"shader_parameter/dissolve_progress",1.0,0.25).set_ease(Tween.EASE_IN_OUT)
			tw.tween_property(as3d,"position:y",-12.0,0.25).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_EXPO)
			tw.parallel().tween_property(as3d,"modulate:a",0.0,0.25).set_ease(Tween.EASE_IN_OUT)
			await tw.finished
			queue_free()
			#do something

func _physics_process(delta : float):
	_knockback()
	if current_state == state.OKAY: match enemy_movement:
		t.STILL: pass
		t.CHASE: process_chase(delta)
		t.PATROL: process_patrol(delta)

var do_knock := false
var ktw : Tween
func _knockback() -> void:
	if do_knock: do_knock = false
	else: return
	if ktw: ktw.kill()
	ktw = create_tween()
	var kmod := 0.0
	var player : PlatformerController2D = get_tree().get_first_node_in_group("player")
	if player:
		if global_position.x < player.global_position.x: kmod = -8.0
		else: kmod = 8.0
	else: 
		if as3d.flip_h: kmod = 8.0
		else: kmod = -8.0
	ktw.tween_property(self,"global_position:x",global_position.x + kmod,0.25).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)

func process_chase(delta : float): pass

@onready var floor_check : RayCast2D = $floorCheck
func process_patrol(delta : float):
	if is_flying: pass
	else:
		match as3d.flip_h:
			true when floor_check: floor_check.position.x = -16.0
			false when floor_check: floor_check.position.x = 16.0
		var check := true
		if floor_check: 
			#floor_check.force_raycast_update()
			check = floor_check.is_colliding()
		if !check: 
			as3d.flip_h = !as3d.flip_h
			return
		if is_zero_approx(velocity.x): as3d.flip_h = !as3d.flip_h
		velocity.x = -MOVE_SPEED if as3d.flip_h else MOVE_SPEED
		velocity.x *= movement_speed
		move_and_slide() 





















#
