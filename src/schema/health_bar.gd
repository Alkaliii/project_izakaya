extends TextureProgressBar
class_name MainHealthBar

@onready var hbedge : Control = $hbedge

var vtw : Tween
var static_value := 1.0
func set_bar_value(nv : int):
	var per := float(nv) / max_value
	static_value = nv
	if vtw: vtw.kill()
	vtw = get_tree().create_tween()
	vtw.tween_property(self,"value",nv,0.25).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	if nv > 0 and nv != max_value:
		vtw.parallel().tween_property(hbedge,"modulate:a",1.0,0.125)
	else: 
		vtw.parallel().tween_property(hbedge,"modulate:a",0.0,0.125)
	vtw.parallel().tween_property(hbedge,"position:x",ceilf(size.x * per) - 6.0,0.25).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
