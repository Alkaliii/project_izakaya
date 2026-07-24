extends Node


@export var player_controller : PlatformerController2D
@export var camera : PhantomCamera2D
@export var attack_box : Hitbox2D
@export var detect_box : Hurtbox2D
@export var airburst_parent : Node2D
@export var airburst_left : CPUParticles2D
@export var airburst_right : CPUParticles2D
@export_group("UI")
@export var health_bar : MainHealthBar
@export var fry_cnt_dwn : RichTextLabel

@export_group("Debug")
@export var debug_speed : RichTextLabel
@export var debug_anim : RichTextLabel

func _ready():
	player_controller.add_to_group("player")
	player_controller.attack.connect(on_attack)
	player_controller.jump_performed.connect(on_jump)
	player_controller.atk_finisher.connect(on_atk_finisher)
	detect_box.detected.connect(on_detect)
	detect_box.detected_area.connect(on_detect_area)
	Dungeon.fairy_countdown.connect(on_fairy_countdown)

var invulnerable_timer : SceneTreeTimer
func on_detect(s : bool,tag : Hitbox2D.tags):
	if tag == Hitbox2D.tags.ENEMY and s and !player_controller.disabled and !player_controller.stunned:
		if invulnerable_timer:
			if invulnerable_timer.time_left == 0.0: invulnerable_timer = null
			else: return
		invulnerable_timer = get_tree().create_timer(2.0)
		player_controller.stunned = true
		player_controller.do_knock = true
		player_controller._knockback()
		player_controller.play_animation("hurt")
		player_controller.health -= 1
		player_controller.playerSprite.material.set_shader_parameter("hit",true)
		await get_tree().create_timer(0.25).timeout
		player_controller.playerSprite.material.set_shader_parameter("hit",false)
		player_controller.stunned = false
		if player_controller.health != 0:
			player_controller.playerSprite.material.set_shader_parameter("soft_flash",true)
			player_controller.play_animation("idle")
			await invulnerable_timer.timeout
			player_controller.playerSprite.material.set_shader_parameter("soft_flash",false)

var ladder_areas : Array[Area2D] = []
func on_detect_area(s : bool,tag : Hitbox2D.tags,area : Area2D):
	if tag == Hitbox2D.tags.LADDER: 
		if s and !ladder_areas.has(area): ladder_areas.append(area)
		elif ladder_areas.has(area): ladder_areas.erase(area)
		player_controller.specialMovements[0]._set_special_flag("near_ladder",!ladder_areas.is_empty())
		if player_controller.specialMovements[0]._get_special_flag("climbing_ladder") and Input.is_action_pressed("move_up") and ladder_areas.is_empty():
			player_controller.specialMovements[0]._set_special_flag("block_ladder",true)
			player_controller._jump(true)

var cfcd := -1
var fctw : Tween
func on_fairy_countdown(nc : int):
	if nc == cfcd: return
	cfcd = nc
	if cfcd != -1:
		fry_cnt_dwn.show()
		if fctw: fctw.kill()
		fctw = create_tween()
		fry_cnt_dwn.text = str("[wave]",cfcd)
		fctw.tween_property(fry_cnt_dwn,"offset_transform_scale",Vector2.ONE,0.25).from(Vector2.ONE * 0.8).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
		fctw.parallel().tween_property(fry_cnt_dwn,"offset_transform_rotation",0.0,0.25).from([deg_to_rad(-30),deg_to_rad(30)].pick_random()).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
		fctw.parallel().tween_property(fry_cnt_dwn,"modulate:a",1.0,0.25).set_ease(Tween.EASE_IN_OUT)
		if cfcd == 0: fctw.tween_property(fry_cnt_dwn,"modulate:a",0.0,0.25).set_ease(Tween.EASE_IN_OUT)
	else:
		if fctw: fctw.kill()
		fctw = create_tween()
		fctw.tween_property(fry_cnt_dwn,"modulate:a",0.0,0.25).set_ease(Tween.EASE_IN_OUT)
		fctw.tween_callback(func():
			fry_cnt_dwn.hide()
			fry_cnt_dwn.modulate.a = 1.0
		)

var airborne := false
func _process(delta : float):
	var on_floor := player_controller.is_on_floor()
	if !on_floor and player_controller.velocity.y > 1.0: 
		camera.dead_zone_height = lerpf(camera.dead_zone_height,0.0,2.0 * delta)
		camera.lookahead_time.y = 0.1
	else: 
		camera.dead_zone_height = lerpf(camera.dead_zone_height,0.5,1.0 * delta)
		camera.lookahead_time.y = 0.0
	
	if !on_floor and !airborne: airborne = true
	if on_floor and airborne:
		airborne = false
		player_controller.specialMovements[0]._set_special_flag("block_ladder",false)
		if !airburst_left.emitting:
			airburst_parent.position.y = 9.0
			airburst_left.restart()
			airburst_right.restart()

	if attack_box:
		attack_box.position.x = -16.0 if player_controller.playerSprite.flip_h else 16.0
		if Input.is_action_pressed("move_up") or (Input.is_action_pressed("jump") and !on_floor): attack_box.position.y = -8.0
		elif !on_floor: attack_box.position.y = 8.0
		else: attack_box.position.y = 0
	
	if Input.is_action_just_pressed("move_up") and !ladder_areas.is_empty():
		var lxpos := ladder_areas[0].global_position.x
		create_tween().tween_property(player_controller,"global_position:x",lxpos,0.1).set_ease(Tween.EASE_IN_OUT)
	
	debug_control()
	health_bar_management()

func health_bar_management():
	if player_controller.health == 0 and !player_controller.disabled:
		player_controller.disabled = true
		player_controller.play_animation("kneel_over")
	elif player_controller.health != 0 and player_controller.disabled:
		invulnerable_timer = get_tree().create_timer(0.5)
		player_controller.playerSprite.material.set_shader_parameter("soft_flash",true)
		player_controller.disabled = false
		player_controller.play_animation("idle")
		await invulnerable_timer.timeout
		player_controller.playerSprite.material.set_shader_parameter("soft_flash",false)
	if player_controller.health != health_bar.static_value:
		health_bar.set_bar_value(player_controller.health)
	# check dead here

func debug_control():
	if debug_speed: debug_speed.text = str("v: ",player_controller.velocity.round())
	if debug_anim: debug_anim.text = str("a: ",player_controller.playerSprite.animation)
	if Input.is_action_just_pressed("debug_a"): player_controller.health -= 1
	if Input.is_action_just_pressed("debug_b"): pass
	if Input.is_action_just_pressed("debug_c"): pass

func on_jump():
	airburst_parent.position.y = 14.0
	airburst_left.restart()
	airburst_right.restart()

func on_atk_finisher():
	invulnerable_timer = get_tree().create_timer(0.5)
	airburst_parent.position.y = 9.0
	if !player_controller.playerSprite.flip_h: airburst_left.restart()
	else: airburst_right.restart()

func on_attack(state : bool):
	for bx in attack_box.get_children():
		if bx is CollisionPolygon2D: bx.set_deferred("disabled",!state)
		elif bx is CollisionShape2D: bx.set_deferred("disabled",!state)
