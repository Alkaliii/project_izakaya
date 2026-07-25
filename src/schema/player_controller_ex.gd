extends Node


@export var player_controller : PlatformerController2D
@export var camera : PhantomCamera2D
@export var attack_box : Hitbox2D
@export var detect_box : Hurtbox2D
@export var airburst_parent : Node2D
@export var airburst_left : CPUParticles2D
@export var airburst_right : CPUParticles2D
@export var pcollide : CollisionShape2D
@export var acl : RayCast2D
@export var acr : RayCast2D
@export_group("UI")
@export var notice_icon : Sprite2D
@export var text_box : TextBox2D
@export var health_bar : MainHealthBar
@export var exp_bar : MainHealthBar
@export var fry_cnt_dwn : RichTextLabel
@export var hurt_emp : ColorRect

@export_group("Debug")
@export var debug_speed : RichTextLabel
@export var debug_anim : RichTextLabel
@export var debug_exp : RichTextLabel

func _ready():
	player_controller.level = Dungeon.get_level()
	player_controller.add_to_group("player")
	player_controller.attack.connect(on_attack)
	player_controller.jump_performed.connect(on_jump)
	player_controller.atk_finisher.connect(on_atk_finisher)
	detect_box.detected.connect(on_detect)
	detect_box.detected_area.connect(on_detect_area)
	Dungeon.fairy_countdown.connect(on_fairy_countdown)
	Dungeon.set_cam_lim.connect(on_camera_lim)
	Dungeon.play_dialog.connect(on_dialog)
	Dungeon.end_dialog.connect(end_dialog)
	Dungeon.move_player.connect(move_to)
	await get_tree().process_frame
	set_up_exp()
	player_controller.exp_changed.connect(set_up_exp)

func on_dialog(txt : String, nme : String = "???",important := false):
	if is_processing(): stop_player(true)
	text_box.disp_text(txt,nme,important)

func end_dialog(): 
	text_box.stop_text()
	stop_player(false)

func stop_player(s : bool):
	# don't ask
	if s:
		set_process(!s)
		player_controller.disabled = s
		player_controller.play_animation("idle")
	else:
		player_controller.disabled = s
		set_process(!s)
	if s and notice_icon.visible: notice_icon.hide()

var mtw : Tween
func move_to(pos : Vector2,look : Vector2 = Vector2.INF):
	if mtw: mtw.kill()
	mtw = create_tween()
	mtw.tween_property(player_controller,"global_position",pos,0.25).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	mtw.tween_callback(func():
		if look != Vector2.INF:
			player_controller.playerSprite.flip_h = player_controller.global_position.x > look.x
	)

var invulnerable_timer : SceneTreeTimer
func on_detect(s : bool,tag : Hitbox2D.tags):
	if tag == Hitbox2D.tags.ENEMY and s and !player_controller.disabled and !player_controller.stunned:
		if invulnerable_timer:
			if invulnerable_timer.time_left == 0.0: invulnerable_timer = null
			else: return
		if !is_processing(): return
		invulnerable_timer = get_tree().create_timer(2.0)
		player_controller.stunned = true
		player_controller.do_knock = true
		player_controller._knockback()
		do_hurt_emp()
		player_controller.play_animation("hurt")
		player_controller.health -= 1
		player_controller.exp -= int(roundf(float(player_controller.exp) * 0.33))
		Dungeon.AM.play(Symphony.SFX_p[Symphony.SFX.PLAYER_HIT],&"SFX",{AudioStreamArtist.prp.PITCH_RNG:Vector2(0.8,1.2)})
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
var drop_areas : Array[Area2D] = []
var interaction_areas : Array[Area2D] = []
func on_detect_area(s : bool,tag : Hitbox2D.tags,area : Area2D):
	if tag == Hitbox2D.tags.LADDER: 
		if s and !ladder_areas.has(area): ladder_areas.append(area)
		elif ladder_areas.has(area): ladder_areas.erase(area)
		player_controller.specialMovements[0]._set_special_flag("near_ladder",!ladder_areas.is_empty())
		if player_controller.specialMovements[0]._get_special_flag("climbing_ladder") and Input.is_action_pressed("move_up") and ladder_areas.is_empty():
			player_controller.specialMovements[0]._set_special_flag("block_ladder",true)
			player_controller._jump(true)
	if tag == Hitbox2D.tags.DROPTHROUGH:
		if s and !drop_areas.has(area): drop_areas.append(area)
		elif drop_areas.has(area): drop_areas.erase(area)
		player_controller.specialMovements[0]._set_special_flag("can_drop",!drop_areas.is_empty())
	if tag == Hitbox2D.tags.INTERACTION:
		if s and !interaction_areas.has(area): interaction_areas.append(area)
		elif interaction_areas.has(area): interaction_areas.erase(area)
		notice_icon.visible = !interaction_areas.is_empty()

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
var disable_collision_for_drop := false
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
		player_controller.landing_occured.emit()
		player_controller.specialMovements[0]._set_special_flag("block_ladder",false)
		Dungeon.AM.play(Symphony.SFX_p[Symphony.SFX.PLAYER_LAND],&"SFX",{AudioStreamArtist.prp.PITCH_RNG:Vector2(0.8,1.2)})
		if !airburst_left.emitting:
			airburst_parent.position.y = 9.0
			airburst_left.restart()
			airburst_right.restart()

	if attack_box:
		attack_box.position.x = -16.0 if player_controller.playerSprite.flip_h else 16.0
		if Input.is_action_pressed("move_up") or (Input.is_action_pressed("jump") and !on_floor): attack_box.position.y = -8.0
		elif !on_floor: attack_box.position.y = 8.0
		else: attack_box.position.y = 0
	
	# Clip Prevention
	if acl.is_colliding() or acr.is_colliding():
		if player_controller.ktw: player_controller.ktw.kill()
	
	# On Ladder Climb Start
	if Input.is_action_pressed("move_up") and !ladder_areas.is_empty():
		var lxpos := ladder_areas[0].global_position.x
		if !is_equal_approx(player_controller.global_position.x,lxpos):
			create_tween().tween_property(player_controller,"global_position:x",lxpos,0.1).set_ease(Tween.EASE_IN_OUT)
	
	# Dropthrough
	if Input.is_action_pressed("move_down") and Input.is_action_just_pressed("jump") and !drop_areas.is_empty() and !disable_collision_for_drop:
		disable_collision_for_drop = true
		pcollide.disabled = true
	if disable_collision_for_drop and drop_areas.is_empty():
		disable_collision_for_drop = false
		pcollide.disabled = false
	
	#Interact
	if Input.is_action_just_pressed("move_up") and !interaction_areas.is_empty():
		interaction_areas[0].activate()
	
	debug_control()
	health_bar_management()

func set_up_exp():
	exp_bar.max_value = Dungeon.get_needed(player_controller.level + 1)
	var ava := Dungeon.get_unused(player_controller.level,player_controller.exp)
	if exp_bar.static_value != ava:
		exp_bar.set_bar_value(min(ava,exp_bar.max_value))

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
	if debug_exp: debug_exp.text = "lvl: %s, %s/%s" % [player_controller.level,player_controller.exp,Dungeon.get_needed(player_controller.level + 1)]
	if Input.is_action_just_pressed("debug_a"): player_controller.health -= 1
	if Input.is_action_just_pressed("debug_b"):
		var m = [true,false].pick_random()
		if !text_box.visible: m = true
		match m:
			true: 
				text_box.disp_text(
					["Hello, hi, hi, [color=goldenrod]hello[/color], hi, hi, hello",
					"What is up [wave]NYC[/wave]! Welcome to the big show yo yo yo!",
					"Is this mic on? I don't think they can hear me.",
					"So last week I got bit by a dog. I think it [shake]poisoned[/shake] me?"].pick_random(),
					["Ali","Mage","Sign","Sky","Nick"].pick_random(),[true,false].pick_random()
				)
			false: text_box.stop_text()
	if Input.is_action_just_pressed("debug_c"): pass

var hurttw : Tween
func do_hurt_emp():
	if hurttw: hurttw.kill()
	hurttw = create_tween()
	hurttw.tween_property(hurt_emp.material,"shader_parameter/line_density",0.5,0.05).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	hurttw.tween_property(hurt_emp.material,"shader_parameter/line_density",0.0,0.125).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)

func on_jump():
	Dungeon.AM.play(Symphony.SFX_p[Symphony.SFX.PLAYER_JUMP],&"SFX",{AudioStreamArtist.prp.PITCH_RNG:Vector2(0.8,1.2)})
	airburst_parent.position.y = 14.0
	airburst_left.restart()
	airburst_right.restart()

func on_atk_finisher():
	invulnerable_timer = get_tree().create_timer(0.5)
	airburst_parent.position.y = 9.0
	if !player_controller.playerSprite.flip_h: airburst_left.restart()
	else: airburst_right.restart()
	await get_tree().create_timer(0.125).timeout
	if player_controller.playerSprite.flip_h: airburst_left.restart()
	else: airburst_right.restart()

func on_attack(state : bool):
	for bx in attack_box.get_children():
		if bx is CollisionPolygon2D: bx.set_deferred("disabled",!state)
		elif bx is CollisionShape2D: bx.set_deferred("disabled",!state)

func on_camera_lim(limit : float, type : CameraLimit.t):
	match type:
		CameraLimit.t.LEFT: camera.limit_left = int(limit)
		CameraLimit.t.RIGHT: camera.limit_right = int(limit)
		CameraLimit.t.BOTTOM: camera.limit_bottom = int(limit)















#
