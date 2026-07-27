extends Control


@onready var textbox = $MarginContainer/textbox
@onready var level_1 = $MarginContainer/HBoxContainer/Level1
@onready var level_2 = $MarginContainer/HBoxContainer/Level2
@onready var level_3 = $MarginContainer/HBoxContainer/Level3
@onready var fog = $Fog

@export var previewg : GradientTexture1D

func _ready():
	Dungeon.AM.play_music(await Symphony.get_music(Symphony.BGM.TITLE))
	fog.material.set_shader_parameter("color_gardient",previewg)
	level_1.pressed.connect(goto_level.bind(0))
	level_2.pressed.connect(goto_level.bind(1))
	level_3.pressed.connect(goto_level.bind(2))
	
	level_1.mouse_entered.connect(preview_level.bind(0))
	level_2.mouse_entered.connect(preview_level.bind(1))
	level_3.mouse_entered.connect(preview_level.bind(2))
	
	#textbox.stop_text()
	await Dungeon.time_delay(0.25)
	
	var lvl := Dungeon.get_level()
	if Dungeon.prev_lvl < lvl:
		textbox.disp_text("[color=639bff]You leveled up!")
		Dungeon.AM.play(Symphony.SFX_p[Symphony.SFX.LEVEL_UP],&"SFX")
		await Dungeon.dialog_waiting
		await Dungeon.multiInputDelay(["move_up","move_down","move_left","move_right","jump","attack"])
		await Dungeon.multiDelayRelease(["move_up","move_down","move_left","move_right","jump","attack"])
		textbox.disp_text("You are now level %s!" % str(lvl))
		await Dungeon.dialog_waiting
		await Dungeon.multiInputDelay(["move_up","move_down","move_left","move_right","jump","attack"])
		await Dungeon.multiDelayRelease(["move_up","move_down","move_left","move_right","jump","attack"])
	textbox.disp_text("So, where to next?")
	current = level_1
	current.grab_focus()
	current.mouse_entered.emit()
	active = true

var active := false
func _process(_delta):
	if active: process_menu()

var current : Control
func process_menu():
	if Input.is_action_just_pressed("move_left"):
		current = current.get_node(current.focus_previous)
		current.grab_focus()
		current.mouse_entered.emit()
	if Input.is_action_just_pressed("move_right"):
		current = current.get_node(current.focus_next)
		current.grab_focus()
		current.mouse_entered.emit()
	if Input.is_action_just_pressed("attack") and current:
		current.pressed.emit()
		await get_tree().process_frame
		current.grab_focus()

func goto_level(lvl : int):
	active = false
	Dungeon.AM.play_music(await Symphony.get_music(Symphony.BGM.LEVEL))
	match lvl:
		0:
			Dungeon.no_death_ply = true if Dungeon.prev_lvl in [0,-1] else false
			Dungeon.no_timer = true
			Dungeon.no_hit_drac = true
			Dungeon.area_name = "[b]N[/b]eophyte's [b]G[/b]rave"
			Dungeon._load("uid://dh4xd12srb6yw")
		1:
			Dungeon.no_death_ply = false
			Dungeon.no_timer = false
			Dungeon.no_hit_drac = true
			Dungeon.area_name = "[b]S[/b]ubterrestrial [b]G[/b]rave"
			Dungeon._load("uid://y38npjwv55lm")
		2:
			Dungeon.no_death_ply = false
			Dungeon.no_timer = true
			Dungeon.no_hit_drac = false
			Dungeon.area_name = "[b]C[/b]astle [b]G[/b]rave"
			Dungeon._load("uid://cy6ht1kqpxdvp")

const DEFAULT_BACKGROUND_FOG_GRADIENT = preload("uid://cutrwn4kop4bj")
const L_2_FOG = preload("uid://b26742x22s75b")
const L_3_FOG = preload("uid://do4e57ig2836j")
var ptw : Tween
@onready var color_rect : ColorRect = $ColorRect
func preview_level(lvl : int):
	if ptw:ptw.kill()
	ptw = create_tween()
	match lvl:
		0:
			ptw.tween_property(color_rect,"color",Color("303c82"),0.25).set_ease(Tween.EASE_IN_OUT)
			ptw.parallel().tween_method(set_col.bind(0),previewg.gradient.get_color(0),DEFAULT_BACKGROUND_FOG_GRADIENT.gradient.get_color(0),0.25).set_ease(Tween.EASE_IN_OUT)
			ptw.parallel().tween_method(set_col.bind(1),previewg.gradient.get_color(1),DEFAULT_BACKGROUND_FOG_GRADIENT.gradient.get_color(1),0.25).set_ease(Tween.EASE_IN_OUT)
		1:
			ptw.tween_property(color_rect,"color",Color("261420"),0.25).set_ease(Tween.EASE_IN_OUT)
			ptw.parallel().tween_method(set_col.bind(0),previewg.gradient.get_color(0),L_2_FOG.gradient.get_color(0),0.25).set_ease(Tween.EASE_IN_OUT)
			ptw.parallel().tween_method(set_col.bind(1),previewg.gradient.get_color(1),L_2_FOG.gradient.get_color(1),0.25).set_ease(Tween.EASE_IN_OUT)
		2:
			ptw.tween_property(color_rect,"color",Color("28302e"),0.25).set_ease(Tween.EASE_IN_OUT)
			ptw.parallel().tween_method(set_col.bind(0),previewg.gradient.get_color(0),L_3_FOG.gradient.get_color(0),0.25).set_ease(Tween.EASE_IN_OUT)
			ptw.parallel().tween_method(set_col.bind(1),previewg.gradient.get_color(1),L_3_FOG.gradient.get_color(1),0.25).set_ease(Tween.EASE_IN_OUT)

func set_col(col,point):
	previewg.gradient.set_color(point,col)













#
