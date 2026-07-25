extends CharacterBody2D


enum t {
	STILL, #this enemy doesn't move
	CHASE, #this enemy tries to move to the player when the player gets close
	PATROL, # this enemy moves around a specific patrol point
}

enum state {
	NONE,
	OKAY, #do movement
	STUN, #stop movement
	DEAD, #stop movement, despawn, reward exp
}

@export var enemy_movement : t = t.STILL
@export var is_flying := false # this enemy is placed in front of the arena, won't collide with obstacles, and can navigate in all four directions
@export var fly_patrol_distance := 30.0
@export_group("Attributes")
@export_range(0,3,1) var max_health : int = 1
@export var bonus_health : int = 0 #so a boss isn't weak as shit and stronger enemies and stronger player works
@export var contact_damage := true #if this enemy attacks in a special way disable this
@export var movement_speed := 1.0 #48 px per second for grounded enemies, linear interp 1.0 * delta
@export var scale_with_player := false
@export var scale_mod : float = 1.0 # current health += player_level * scale_mod

@export_group("Simple Special Attack")
@export var engagement_dist := 30.0
@export var hurtboxes : Array[Hurtbox2D] = []
@export var timer_threshold : float = 2.5
@export var timer_cooldown : float = 2.5

@onready var as2d : AnimatedSprite2D = $AnimatedSprite2D
@onready var cdbx : Hitbox2D = $ContactDamage
@onready var damage_detect : Hurtbox2D = $DamageDetect


const MOVE_SPEED := 24.0
var current_state : state = state.NONE
var current_health := 3 :
	set(nv):
		current_health = max(nv,0)

var patrol_point := Vector2.ZERO
func _ready():
	patrol_point = global_position
	if is_flying: set_flight_position(true)
	set_flying(is_flying)
	current_health = max_health + bonus_health
	if scale_with_player: current_health += int(ceilf(float(Dungeon.get_level()) * scale_mod))
	set_contact_damage(contact_damage)
	
	if damage_detect: damage_detect.detected.connect(on_detect)
	if as2d.sprite_frames.has_animation("idle"): as2d.play("idle")
	current_state = state.OKAY

func set_contact_damage(s : bool) -> void:
	if cdbx: for c in cdbx.get_children():
		if c is CollisionPolygon2D: c.set_deferred("disabled",!s)
		elif c is CollisionShape2D: c.set_deferred("disabled",!s)

func set_flying(s : bool) -> void:
	as2d.material.set_shader_parameter("do_bounce",s)
	match s:
		true:
			set_collision_layer_value(4,false)
			set_collision_layer_value(5,true)
			set_collision_mask_value(2,false)
			set_collision_mask_value(1,true)
		false:
			set_collision_layer_value(4,true)
			set_collision_layer_value(5,false)
			set_collision_mask_value(2,true)
			set_collision_mask_value(1,false)

#const min_detect_dist := 20
func on_detect(s : bool,tag : Hitbox2D.tags):
	var player : PlatformerController2D = get_tree().get_first_node_in_group("player")
	if tag == Hitbox2D.tags.PLAYER and s and current_state == state.OKAY:
		#if player and (global_position - player.global_position).length() > min_detect_dist: return
		current_state = state.STUN
		set_contact_damage(false)
		if player: as2d.flip_h = global_position.x > player.global_position.x
		var dmg = maxi(1,player.level)
		if player.health > 2: dmg = 0
		if player.health == 1: dmg = int(roundf(float(dmg) * 1.5))
		current_health -= dmg
		Dungeon.spawn_ft(global_position,str("[wave]",dmg))
		
		do_knock = true
		as2d.material.set_shader_parameter("hit",true)
		if as2d.sprite_frames.has_animation("hurt"): 
			as2d.play("hurt")
			await as2d.animation_finished
		else: 
			await get_tree().create_timer(0.5).timeout
		as2d.material.set_shader_parameter("hit",false)
		
		if current_health != 0:
			set_contact_damage(true)
			if as2d.sprite_frames.has_animation("idle"): as2d.play("idle")
			current_state = state.OKAY
		else:
			current_state = state.DEAD
			player.exp += max_health + bonus_health
			Dungeon.spawn_ft(player.global_position,str("[wave][color=639bff]+xp"),1.5)
			var tw := create_tween()
			#tw.tween_property(as3d.material,"shader_parameter/dissolve_progress",1.0,0.25).set_ease(Tween.EASE_IN_OUT)
			tw.tween_property(as2d,"position:y",-12.0,0.25).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_EXPO)
			tw.parallel().tween_property(as2d,"modulate:a",0.0,0.25).set_ease(Tween.EASE_IN_OUT)
			await tw.finished
			queue_free()
			#do something

func _physics_process(delta : float):
	_knockback()
	if current_state == state.OKAY: match enemy_movement:
		t.STILL: pass
		t.CHASE: process_chase(delta)
		t.PATROL: process_patrol(delta)
	else: decel(delta)
	if !is_on_floor() and !is_flying: velocity.y += get_gravity().y
	elif !is_flying: velocity.y = lerpf(velocity.y,0.0,3.0*delta)
	move_and_slide() 

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
		if as2d.flip_h: kmod = 8.0
		else: kmod = -8.0
	ktw.tween_property(self,"global_position:x",global_position.x + kmod,0.25).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)

var flight_hold : SceneTreeTimer
func set_flight_position(unconditional := false):
	var player : PlatformerController2D = get_tree().get_first_node_in_group("player")
	if (global_position - new_flight_position).length() < 10.0 or unconditional:
		if !flight_hold and !unconditional:
			flight_hold = get_tree().create_timer(randf_range(1.5,3.0))
			return
		elif (flight_hold and flight_hold.time_left == 0.0) or unconditional:
			if (patrol_point - player.global_position).length() < fly_patrol_distance:
				# fly near player
				new_flight_position = player.global_position + [get_follow_pos(player),Vector2.ZERO].pick_random()
			else:
				var new_vec := Vector2.UP * fly_patrol_distance
				new_vec = new_vec.rotated(randf_range(-TAU,TAU))
				floor_check.position = Vector2.ZERO
				floor_check.target_position = new_vec
				floor_check.force_raycast_update()
				if floor_check.is_colliding():
					new_vec = (floor_check.get_collision_point() - patrol_point) * 0.9
				new_flight_position = patrol_point + new_vec
			flight_hold = null

func get_follow_pos(player : PlatformerController2D) -> Vector2:
	var new_follow_pos : Vector2 = Vector2.ZERO
	if player.playerSprite.flip_h: new_follow_pos.x = 32.0 #follow_pos.lerp(player.global_position + (Vector2(-1.0,1.0) * -16.0),8.0 * delta)
	else: new_follow_pos.x = -32.0
	if player.is_on_floor(): new_follow_pos.y = -24.0
	else: new_follow_pos.y = 24.0
	
	return new_follow_pos

func process_chase(delta : float): pass

@onready var floor_check : RayCast2D = $floorCheck
var new_flight_position : Vector2 = Vector2.ZERO
func process_patrol(delta : float):
	if is_flying:
		set_flight_position()
		var fspd := clampf((global_position - new_flight_position).length() / 32.0,0.0,0.5) * movement_speed
		global_position = global_position.lerp(new_flight_position,fspd * delta)
		as2d.flip_h = global_position.x > new_flight_position.x
	else:
		match as2d.flip_h:
			true when floor_check: floor_check.position.x = -10.0
			false when floor_check: floor_check.position.x = 10.0
		var check := true
		if floor_check: 
			floor_check.force_raycast_update()
			check = floor_check.is_colliding()
		if !check: 
			as2d.flip_h = !as2d.flip_h
			return
		if is_zero_approx(velocity.x): as2d.flip_h = !as2d.flip_h
		velocity.x = -MOVE_SPEED if as2d.flip_h else MOVE_SPEED
		velocity.x *= movement_speed

func decel(delta : float):
	velocity.x = lerpf(velocity.x,0.0,3.0*delta)




















#
