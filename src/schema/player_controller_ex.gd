extends Node


@export var player_controller : PlatformerController2D
@export var attack_box : Hitbox2D
@export var detect_box : Hurtbox2D

func _ready():
	player_controller.add_to_group("player")
	player_controller.attack.connect(on_attack)

func _process(_delta):
	if attack_box:
		var on_floor := player_controller.is_on_floor()
		attack_box.position.x = -16.0 if player_controller.playerSprite.flip_h else 16.0
		if Input.is_action_pressed("move_up") or (Input.is_action_pressed("jump") and !on_floor): attack_box.position.y = -8.0
		elif !on_floor: attack_box.position.y = 8.0
		else: attack_box.position.y = 0

func on_attack(state : bool):
	for bx in attack_box.get_children():
		if bx is CollisionShape2D: bx.call_deferred("set","disabled",!state)
		elif bx is CollisionPolygon2D: bx.call_deferred("set","disabled",!state)
