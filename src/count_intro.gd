extends Sign2D

@export var check_tut := false
const DRAC_SPAWNER = preload("uid://4nwaayycxyl0")
const WINSCRIPT = preload("uid://brt72bv4kwshd")

func _after_ready():
	Dungeon.banim.connect(play_anim)
	Dungeon.winner.connect(win_scene)
	if check_tut and Dungeon.prev_lvl != -1:
		detect.queue_free()
		interacta.queue_free()
		var new = DRAC_SPAWNER.instantiate()
		add_child(new)

const BOSS_ENEMY = preload("uid://cu4aryopu4mug")

func win_scene():
	WINSCRIPT.play_scp()
	if stand_beside:
		var p : PlatformerController2D = get_tree().get_first_node_in_group("player")
		if p.global_position.x < global_position.x:
			Dungeon.move_player.emit(global_position - Vector2(sb_dist,-sb_height),global_position)
		else: 
			Dungeon.move_player.emit(global_position + Vector2(sb_dist,sb_height),global_position)

@onready var animated_sprite_2d : AnimatedSprite2D = $AnimatedSprite2D
@onready var laughfx = $laughfx
func play_anim(a : String):
	if a == "appear": animated_sprite_2d.show()
	if animated_sprite_2d.sprite_frames.has_animation(a):
		animated_sprite_2d.play(a)
		if a == "appear":
			await animated_sprite_2d.animation_finished
			animated_sprite_2d.play('idle')
	if a == "laugh":
		laughfx.show()
		laughfx.play()
	else: laughfx.hide()
	if a == "disappear":
		animated_sprite_2d.play("appear",-2,true)
		await animated_sprite_2d.animation_finished
		animated_sprite_2d.hide()
		var new = DRAC_SPAWNER.instantiate()
		add_child(new)
	if a == "disappear2":
		animated_sprite_2d.play("appear",-2,true)
		await animated_sprite_2d.animation_finished
		animated_sprite_2d.hide()
		Dungeon.AM.play_music(await Symphony.get_music(Symphony.BGM.BOSS))
		var new := BOSS_ENEMY.instantiate()
		add_child(new)
	if a == "disappear3":
		animated_sprite_2d.play("appear",-2,true)
		await animated_sprite_2d.animation_finished
		animated_sprite_2d.hide()
	if a == "gameover":
		Dungeon._load("uid://6eqo7kytpx8x")
		
