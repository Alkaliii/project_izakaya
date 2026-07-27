extends Control

@onready var title = $CanvasLayer/title
@onready var obsucra = $CanvasLayer/Obsucra
@onready var drac_timer : RichTextLabel = $CanvasLayer/MarginContainer/HBoxContainer/DracTimer

var active := false
func _ready():
	var new : PackedScene = await Dungeon._load("uid://crxdmhhua4w7g",true)
	var ld = new.instantiate()
	add_child(ld)
	await get_tree().process_frame
	ld.z_index = -99
	drac_timer.text = "[wave]Press Any Key"
	await Dungeon.anykey()
	title_intro()

func title_intro():
	var tw = create_tween()
	Dungeon.AM.play(Symphony.SFX_p[Symphony.SFX.ENEMY_ATTACK_B],&"SFX")
	tw.tween_property(title,"modulate:a",1.0,0.125).set_ease(Tween.EASE_IN_OUT)
	tw.parallel().tween_property(obsucra,"modulate:a",0.0,0.125).set_ease(Tween.EASE_IN_OUT)
	tw.tween_callback(
		func():
			title.material.set_shader_parameter("hit",true)
			Dungeon.AM.play_music(await Symphony.get_music(Symphony.BGM.TITLE))
			drac_timer.text = "[X] or [J] to Play"
	)
	tw.tween_property(title.material,"shader_parameter/gsp",0.0,0.25).set_ease(Tween.EASE_IN_OUT)
	tw.parallel().tween_property(drac_timer,"offset_transform_position_ratio:y",5.0,0.25).set_ease(Tween.EASE_IN_OUT)
	tw.tween_callback(
		func():
			title.material.set_shader_parameter("hit",false)
			title.material.set_shader_parameter("do_bounce",true)
			active = true
	)

func _process(_delta):
	if Input.is_action_just_pressed("attack") and active:
		Dungeon.AM.play_music(await Symphony.get_music(Symphony.BGM.LEVEL))
		Dungeon._load("uid://dh4xd12srb6yw")
		Dungeon.no_death_ply = true
		active = false
