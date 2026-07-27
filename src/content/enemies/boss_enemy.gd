extends BaseEnemy2D
class_name CountDOwen

@export var attack_only := false


func _after_ready():
	add_to_group("boss")
	as2d.animation_changed.connect(fix_frame)
	as2d.frame_changed.connect(fix_frame)
	got_hit.connect(on_hit)
	if attack_only: as2d.show()

func is_boss_visible(): return as2d.visible

var invulnerable := false
var uninterruptable := false
func on_hit():
	#50 % chance to disappear after hit
	if invulnerable or Dungeon.no_hit_drac: 
		if Dungeon.no_hit_drac: Dungeon.spawn_ft(global_position,str("[shake rate=20 level=6]0",))
		return
	$laughfx.hide()
	current_state = state.STUN
	set_contact_damage(false)
	var dmg = maxi(1,player.level)
	if player: 
		if player.health > 2: dmg = 0
		if player.health == 1: dmg = int(roundf(float(dmg) * 1.5))
		as2d.flip_h = global_position.x < player.global_position.x
		var sev := 0
		if dmg >= current_health: sev = 2
		if dmg == 0: sev = 0
		Dungeon.play_hit(
			(global_position + player.global_position) / 2.0,sev,!as2d.flip_h
		)
	current_health -= dmg
	Dungeon.AM.play(Symphony.SFX_p[Symphony.SFX.ENEMY_HIT],&"SFX",{AudioStreamArtist.prp.PITCH_RNG:Vector2(0.9,1.2)})
	#if current_health <= 0: Dungeon.hitstop()
	Dungeon.spawn_ft(global_position,str("[wave]",dmg))
	
	do_knock = true
	as2d.material.set_shader_parameter("hit",true)
	if as2d.sprite_frames.has_animation("hurt") and !uninterruptable and current_action != action.ATTACK: 
		as2d.play("hurt")
		await as2d.animation_finished
	else: 
		await get_tree().create_timer(0.5).timeout
	as2d.material.set_shader_parameter("hit",false)
	
	if current_health != 0:
		set_contact_damage(true)
		if as2d.sprite_frames.has_animation("idle") and !uninterruptable: 
			if [true,false].pick_random() and !fr_cd:
				as2d.play("idle")
			elif fr_cd or current_action == action.ATTACK: as2d.play("idle")
			else:
				force_retreat = true
				action_cd = null
		if fr_cd and fr_cd.time_left == 0.0: fr_cd = null
		current_state = state.OKAY
	else:
		current_state = state.DEAD
		var earned = max_health + bonus_health
		if player.health == 1: earned = int(round(float(earned) * 1.5))
		player.exp += earned
		Dungeon.spawn_ft(player.global_position,str("[wave][color=639bff]+xp"),1.5)
		var tw := create_tween()
		#tw.tween_property(as3d.material,"shader_parameter/dissolve_progress",1.0,0.25).set_ease(Tween.EASE_IN_OUT)
		tw.tween_property(as2d,"position:y",-12.0,0.25).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_EXPO)
		tw.parallel().tween_property(as2d,"modulate:a",0.0,0.25).set_ease(Tween.EASE_IN_OUT)
		tw.tween_callback(func(): im_dead.emit())
		await tw.finished
		for i in current_spawns: spawn_kill()
		Dungeon.winner.emit()
		queue_free()

func fix_frame(wait := false):
	if wait: await as2d.frame_changed
	var frame := as2d.sprite_frames.get_frame_texture(as2d.animation,as2d.frame).get_size()
	if as2d.flip_h:
		if frame.x > 16.0:
			as2d.offset.x = -frame.x + 8.0
		else: as2d.offset.x = -8.0
	else: 
		as2d.offset.x = -8.0
	as2d.offset.y = -frame.y + 8

func _physics_process(delta : float):
	_knockback()
	if current_state == state.OKAY: special_process()
	else: decel(delta)
	var new_off = 48 if as2d.flip_h else -48
	camera.follow_offset.x = lerpf(camera.follow_offset.x,new_off,1.0 * delta)
	if !is_on_floor() and !is_flying: velocity.y += get_gravity().y
	elif !is_flying: velocity.y = lerpf(velocity.y,0.0,3.0*delta)
	move_and_slide()

var current_spawns : Array[BaseEnemy2D] = []
var unbroken_attacks : int = 0

var force_retreat := false
var fr_cd : SceneTreeTimer
const pattern : Array[action] = [
	action.HOLD,
	action.APPEAR,
	action.SPAWN,
	action.HOLD,
	action.SPAWN,
	action.ATTACK,
	action.ATTACK,
	action.HOLD,
	action.ATTACK,
	action.APPEAR,
	action.SPAWN,
	action.SPAWN,
	action.HOLD,
	action.ATTACK,
	action.RETREAT,
	action.ATTACK,
	action.ATTACK,
	action.ATTACK,
	action.ATTACK,
	action.SPAWN,
	action.SPAWN,
]
var state_idx := 0
func get_next_state() -> action:
	if attack_only: return [action.ATTACK,action.HOLD].pick_random()
	if force_retreat: 
		fr_cd = get_tree().create_timer(3.0)
		return action.RETREAT
	state_idx += 1
	return pattern[state_idx % pattern.size()]
	match current_action:
		action.HOLD: 
			unbroken_attacks = 0
			return [action.SPAWN,action.ATTACK].pick_random()
			#var pick : Array[action] = [action.HOLD]
			#if current_spawns.size() != 2: pick.append(action.SPAWN)
			#else: pick.append(action.RETREAT)
			#return pick.pick_random()
		action.ATTACK: 
			unbroken_attacks += 1
			if unbroken_attacks < 3:
				return action.ATTACK
			else: return action.HOLD
			#var pick : Array[action] = [action.APPEAR]
			#if current_spawns.size() != 2: pick.append(action.SPAWN)
			#if unbroken_attacks < 3: pick.append(action.ATTACK)
			#return pick.pick_random()
		action.SPAWN: return action.RETREAT
			#unbroken_attacks = 0
			#var pick : Array[action] = [action.HOLD,action.ATTACK]
			#return pick.pick_random()
		action.RETREAT: return action.HOLD
			#unbroken_attacks = 0
			#return [action.HOLD,action.SPAWN,action.ATTACK].pick_random()
		action.APPEAR: return action.ATTACK
			#unbroken_attacks = 0
			#return [action.ATTACK,action.SPAWN].pick_random()
	return action.HOLD

enum action {
	HOLD, #stand still
	ATTACK, #teleports beside you, sends a wave across the ground in your direction
	RETREAT, #disappears
	SPAWN, #appears (if not visible) and creates a mob (if under limit)
	APPEAR, #just appears
}
#as2d.play(["appear","attack","hurt","windup","idle","retreat"].pick_random())
var current_action : action = action.HOLD
var action_cd : SceneTreeTimer
func special_process():
	#return
	if player.disabled or player.stunned: 
		if as2d.visible and current_action != action.ATTACK: 
			as2d.play("laugh")
			$laughfx.show()
			$laughfx.play()
		return
	if $laughfx.visible and current_action != action.HOLD: $laughfx.hide()
	
	if current_action == action.HOLD: uninterruptable = false
	if current_action in [action.ATTACK] and as2d.animation == "windup":
		as2d.flip_h = global_position.x < player.global_position.x
	if current_action in [action.SPAWN]:
		as2d.flip_h = global_position.x < player.global_position.x
	
	if action_cd:
		if action_cd.time_left == 0.0: action_cd = null
		return
	action_cd = get_tree().create_timer(maxf(5.0 * (float(current_health) / float(inital_health)),2.0))
	current_action = get_next_state()
	await do_action()
	#if [true,false].pick_random() and current_state != action.ATTACK: action_cd = null

@onready var attack_vfx = $AttackVFX
@onready var attack_vfx_2 = $AttackVFX2
@onready var atkbx = $AttackVFX/Hitbox2D
@onready var atkbx2 = $AttackVFX2/Hitbox2D
@onready var camera = $CameraParent/PhantomCamera2D
var attw : Tween
func do_attack():
	as2d.play("attack")
	if attw: attw.kill()
	attack_vfx.flip_h = as2d.flip_h
	attack_vfx.position.x = 8 if as2d.flip_h else -8
	attack_vfx.show()
	attack_vfx.play()
	set_attack_damage(true)
	await attack_vfx.frame_changed
	Dungeon.AM.play(Symphony.SFX_p[Symphony.SFX.ENEMY_ATTACK_A],&"SFX")
	attw = create_tween()
	attw.tween_property(attack_vfx,"position:x",32 if as2d.flip_h else -32,0.25).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	await attack_vfx.animation_finished
	set_attack_damage(false)
	attack_vfx.hide()

const BOOK_ENEMY = preload("uid://obibigkx4gtt")
const SCALING_ENEMY = preload("uid://bl6t103brt3yi")
var sptw : Tween
var sp_cd : SceneTreeTimer
func spawn_add():
	uninterruptable = true
	sp_cd = get_tree().create_timer(5.0)
	var new : BaseEnemy2D = [BOOK_ENEMY,SCALING_ENEMY].pick_random().instantiate()
	new.scale_with_player = true
	new.enemy_movement = BaseEnemy2D.t.CHASE
	if new.is_flying: new.chase_engage_distance = 96
	new.patrol_point = camera.global_position
	new.new_flight_position = player.global_position + Vector2(48 if global_position.x < player.global_position.x else -48,0)
	Dungeon.add_child(new)
	new.global_position = global_position + [Vector2(8,0),Vector2(-8,0)].pick_random()
	new.im_dead.connect(clean_spawns.bind(new))
	current_spawns.append(new)
	if sptw: sptw.kill()
	sptw = create_tween()
	sptw.tween_property(as2d,"scale",Vector2.ONE * 1.2,0.25).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
	sptw.tween_property(as2d,"scale",Vector2.ONE,0.25).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CIRC)
	await sptw.finished
	uninterruptable = false

func spawn_kill():
	await current_spawns.pick_random().kill(true)

func clean_spawns(d : BaseEnemy2D):
	current_spawns.erase(d)

var attw2 : Tween
@onready var interaction_notice = $InteractionNotice
func double_attack():
	interaction_notice.show()
	do_attack()
	await as2d.animation_finished
	interaction_notice.hide()
	as2d.play("attack",-2.0,true)
	if attw2: attw2.kill()
	attack_vfx_2.flip_h = as2d.flip_h
	attack_vfx_2.position.x = 8 if as2d.flip_h else -8
	attack_vfx_2.show()
	attack_vfx_2.play("default",-1.0,true)
	set_attack_damage_b(true)
	await attack_vfx_2.frame_changed
	Dungeon.AM.play(Symphony.SFX_p[Symphony.SFX.ENEMY_ATTACK_B],&"SFX")
	attw2 = create_tween()
	attw2.tween_property(attack_vfx_2,"position:x",48 if as2d.flip_h else -48,0.3).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	await attack_vfx_2.animation_finished
	set_attack_damage_b(false)
	attack_vfx_2.hide()

func set_attack_damage(s : bool) -> void:
	if s and !as2d.visible: return
	if atkbx: for c in atkbx.get_children():
		if c is CollisionPolygon2D: c.set_deferred("disabled",!s)
		elif c is CollisionShape2D: c.set_deferred("disabled",!s)

func set_attack_damage_b(s : bool) -> void:
	if s and !as2d.visible: return
	if atkbx2: for c in atkbx2.get_children():
		if c is CollisionPolygon2D: c.set_deferred("disabled",!s)
		elif c is CollisionShape2D: c.set_deferred("disabled",!s)

func disappear(cowardly := false):
	uninterruptable = true
	invulnerable = true
	set_contact_damage(false)
	if cowardly: as2d.play("retreat",2.0)
	else: as2d.play("appear",-2.0,true)
	await as2d.animation_finished
	as2d.hide()
	if force_retreat: force_retreat = false
	if [true,false].pick_random():
		move_left()
	else: move_right()

func appear():
	as2d.show()
	invulnerable = false
	as2d.play("appear")
	Dungeon.AM.play(Symphony.SFX_p[Symphony.SFX.BOSS_APPEAR],&"SFX")
	await as2d.animation_finished
	set_contact_damage(true)
	if !fr_cd: fr_cd = get_tree().create_timer(0.5)

func move_left():
	floor_check.global_position = global_position - Vector2(16.0,0.0)
	floor_check.force_raycast_update()
	if floor_check.is_colliding() and floor_check.get_collision_point().y > global_position.y:
		global_position = floor_check.global_position
		as2d.flip_h = global_position.x < player.global_position.x

func move_right():
	floor_check.global_position = global_position + Vector2(16.0,0.0)
	floor_check.force_raycast_update()
	if floor_check.is_colliding() and floor_check.get_collision_point().y > global_position.y:
		global_position = floor_check.global_position
		as2d.flip_h = global_position.x < player.global_position.x

func tp_to_player() -> bool:
	## check right
	floor_check.global_position = player.global_position + Vector2(16.0,0.0)
	floor_check.force_raycast_update()
	if floor_check.is_colliding() and floor_check.get_collision_point().y > global_position.y:
		global_position = floor_check.global_position
		as2d.flip_h = global_position.x < player.global_position.x
		return true
	## check left
	floor_check.global_position = player.global_position - Vector2(16.0,0.0)
	floor_check.force_raycast_update()
	if floor_check.is_colliding() and floor_check.get_collision_point().y > player.global_position.y:
		global_position = floor_check.global_position
		as2d.flip_h = global_position.x < player.global_position.x
		return true
	return false

func inverse_tp_to_player() -> bool:
	## check left
	floor_check.global_position = player.global_position - Vector2(16.0,0.0)
	floor_check.force_raycast_update()
	if floor_check.is_colliding() and floor_check.get_collision_point().y > player.global_position.y:
		global_position = floor_check.global_position
		as2d.flip_h = global_position.x < player.global_position.x
		return true
	## check right
	floor_check.global_position = player.global_position + Vector2(16.0,0.0)
	floor_check.force_raycast_update()
	if floor_check.is_colliding() and floor_check.get_collision_point().y > global_position.y:
		global_position = floor_check.global_position
		as2d.flip_h = global_position.x < player.global_position.x
		return true
	return false

func do_action():
	match current_action:
		action.HOLD:
			invulnerable = false
			if [true,false].pick_random():
				as2d.play("idle")
			elif as2d.visible:
				as2d.play("laugh")
				$laughfx.show()
				$laughfx.play()
				$laughfx.position.x = -8 if as2d.flip_h else 8
			if as2d.visible and !attack_only:
				await get_tree().create_timer(randf_range(1.0,6.0)).timeout
			else:
				await get_tree().create_timer(1.0).timeout
			$laughfx.hide()
		action.ATTACK:
			# disappear
			uninterruptable = true
			if as2d.visible: 
				await disappear()
				await get_tree().create_timer(randf_range(0.5,1.0)).timeout
			# move to player
			var res : bool = false
			if [true,false].pick_random(): res = tp_to_player()
			else: 
				res = inverse_tp_to_player()
			if res: 
				Dungeon.stun_player.emit(global_position.x < player.global_position.x)
				if !attack_only: camera.priority = 2
				camera.follow_offset.x = 48 if as2d.flip_h else -48
			# appear
			await appear()
			# windup (no anim change, just flash)
			as2d.play("windup")
			await as2d.animation_finished
			# attack (invlunerable)
			invulnerable = true
			if [true,false].pick_random():
				await double_attack()
			else: await do_attack()
			#await as2d.animation_finished
			# spawn attack obj
			camera.priority = 0
			await get_tree().create_timer(0.5).timeout
			# retreat
			await disappear()
			await get_tree().create_timer(randf_range(0.5,1.0)).timeout
		action.SPAWN:
			if !as2d.visible:
				as2d.flip_h = global_position.x < player.global_position.x
				await appear()
			if current_spawns.size() != 2: 
				await spawn_add()
				as2d.play("idle")
				uninterruptable = false
			elif !sp_cd: 
				as2d.play("idle")
				await spawn_kill()
				uninterruptable = false
			else:
				if sp_cd and sp_cd.time_left == 0.0: sp_cd = null
				as2d.play("idle")
				uninterruptable = false
			await get_tree().create_timer(randf_range(1.0,2.0)).timeout
		action.RETREAT:
			if force_retreat: await disappear(true)
			else: await disappear()
			await get_tree().create_timer(randf_range(1.0,2.0)).timeout
		action.APPEAR: 
			if !as2d.visible:
				as2d.flip_h = global_position.x < player.global_position.x
				await appear()
				uninterruptable = false







#
