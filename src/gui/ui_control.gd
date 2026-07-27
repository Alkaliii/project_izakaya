extends Node
class_name guiManager

# I make it obvious which element is focused when navigating with keyboard
const UI_FOCUSED_MAT = preload("uid://dr2b0puqt213b")
var parent : Control

enum ad {
	UP,
	DOWN,
	LEFT,
	RIGHT,
}
@export var anim_dir : ad = ad.UP

func _ready():
	parent = get_parent()
	if !parent: return
	parent.offset_transform_enabled = true
	if parent is Button:
		parent.pressed.connect(press_anim)
		parent.focus_entered.connect(focus.bind(true))
		parent.focus_exited.connect(focus.bind(false))

func focus(s : bool):
	if s:
		parent.z_index = 1
		parent.material = UI_FOCUSED_MAT
		if anim_dir != ad.DOWN:
			Dungeon.AM.play(Symphony.SFX_p[Symphony.SFX.MENU_SEL],&"SFX") #,{AudioStreamArtist.prp.PITCH_RNG:Vector2(0.9,1.1)}
		else: Dungeon.AM.play(Symphony.SFX_p[Symphony.SFX.MENU_BACK],&"SFX") #,{AudioStreamArtist.prp.PITCH_RNG:Vector2(0.8,1.2)}
	else:
		parent.z_index = 0
		parent.material = null

var ptw : Tween
func press_anim():
	if ptw: ptw.kill()
	ptw = create_tween()
	var dir : Vector2
	match anim_dir:
		ad.UP: dir = Vector2.DOWN
		ad.DOWN: dir = Vector2.UP
		ad.LEFT: dir = Vector2.RIGHT
		ad.RIGHT: dir = Vector2.LEFT
	ptw.tween_property(parent,"offset_transform_position_ratio",dir * -0.2,0.1).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
	ptw.tween_property(parent,"offset_transform_position_ratio",Vector2.ZERO,0.1).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	parent.release_focus()



#
