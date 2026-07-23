extends Node


@export var player_controller : PlatformerController2D
@export var camera : PhantomCamera2D
@export var attack_box : Hitbox2D
@export var detect_box : Hurtbox2D
@export var airburst_parent : Node2D
@export var airburst_left : CPUParticles2D
@export var airburst_right : CPUParticles2D


@export_group("Debug")
@export var debug_speed : RichTextLabel
@export var debug_anim : RichTextLabel

func _ready():
	player_controller.add_to_group("player")
	player_controller.attack.connect(on_attack)
	player_controller.jump_performed.connect(on_jump)
	player_controller.atk_finisher.connect(on_atk_finisher)

var airborne := false
func _process(delta : float):
	var on_floor := player_controller.is_on_floor()
	if !on_floor and player_controller.velocity.y > 1.0: 
		camera.dead_zone_height = lerpf(camera.dead_zone_height,0.0,2.0 * delta)
	else: camera.dead_zone_height = lerpf(camera.dead_zone_height,0.5,1.0 * delta)
	
	if !on_floor and !airborne: airborne = true
	if on_floor and airborne:
		airborne = false
		if !airburst_left.emitting:
			airburst_parent.position.y = 9.0
			airburst_left.restart()
			airburst_right.restart()

	if attack_box:
		attack_box.position.x = -16.0 if player_controller.playerSprite.flip_h else 16.0
		if Input.is_action_pressed("move_up") or (Input.is_action_pressed("jump") and !on_floor): attack_box.position.y = -8.0
		elif !on_floor: attack_box.position.y = 8.0
		else: attack_box.position.y = 0
	if debug_speed: debug_speed.text = str("v: ",player_controller.velocity.round())
	if debug_anim: debug_anim.text = str("a: ",player_controller.playerSprite.animation)

func on_jump():
	airburst_parent.position.y = 14.0
	airburst_left.restart()
	airburst_right.restart()

func on_atk_finisher():
	airburst_parent.position.y = 9.0
	if player_controller.playerSprite.flip_h: airburst_left.restart()
	else: airburst_right.restart()

func on_attack(state : bool):
	for bx in attack_box.get_children():
		if bx is CollisionShape2D: bx.call_deferred("set","disabled",!state)
		elif bx is CollisionPolygon2D: bx.call_deferred("set","disabled",!state)
