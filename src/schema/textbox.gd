extends PanelContainer
class_name TextBox2D

@onready var nmetag = $vbc/tbx/c/nmetag
@onready var tbxlbl : RichTextLabel = $vbc/tbx/mc/hbc/tbxlbl
@onready var ntglbl : RichTextLabel = $vbc/tbx/c/nmetag/mc/ntglbl
@onready var alert : TextureRect = $alert
@onready var ci : TextureRect = $vbc/tbx/mc/continue
@onready var mc = $vbc/tbx/mc


func _ready():
	offset_transform_scale = Vector2.ZERO
	hide()

func disp_text(txt : String, nme : String = "???",important := false):
	await _set_text(txt,nme,important)
	_show_text(true)

func stop_text():
	_show_text(false)

func _set_text(txt : String, nme : String = "???", important := false) -> void:
	if nme:
		nmetag.show()
		ntglbl.text = nme
	else: nmetag.hide()
	if important: 
		mc.add_theme_constant_override("margin_left",16)
		alert.show()
	else: 
		mc.add_theme_constant_override("margin_left",4)
		alert.hide()
	ci.hide()
	tbxlbl.visible_ratio = 0.0
	await get_tree().process_frame
	tbxlbl.text = txt

var ttw : Tween
func _show_text(s : bool) -> void:
	if !visible and s: await _show_box(true)
	if ttw: ttw.kill()
	ttw = create_tween()
	match s:
		true: 
			Dungeon.AM.play(Symphony.SFX_p[Symphony.SFX.MENU_SEL],&"SFX")
			ttw.tween_property(tbxlbl,"visible_ratio",1.0,0.25).set_ease(Tween.EASE_IN_OUT)
			ttw.tween_callback(ci.show)
			ttw.tween_callback(func(): Dungeon.dialog_waiting.emit())
		false: 
			ttw.tween_property(tbxlbl,"visible_ratio",0.0,0.25).set_ease(Tween.EASE_IN_OUT)
			_show_box(false)
	await ttw.finished

var bxtw : Tween
func _show_box(s : bool) -> void:
	if bxtw: bxtw.kill()
	bxtw = create_tween()
	match s:
		true:
			bxtw.tween_callback(show)
			bxtw.tween_property(self,"offset_transform_scale",Vector2.ONE,0.25).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUAD)
		false:
			Dungeon.AM.play(Symphony.SFX_p[Symphony.SFX.MENU_BACK],&"SFX")
			bxtw.tween_property(self,"offset_transform_scale",Vector2.ZERO,0.25).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUAD)
			bxtw.tween_callback(hide)
	await bxtw.finished
