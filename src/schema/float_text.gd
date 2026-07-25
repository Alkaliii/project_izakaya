extends Node2D
class_name FloatingText2D

# appears for set amount of time then disappears

var hold_time := 3.0
var active := false

@onready var lbl = $cc/lbl

var tw : Tween
func _ready():
	modulate.a = 0.0
	await get_tree().process_frame
	global_position.x += randi_range(-3,3)
	active = true
	tw = create_tween()
	tw.tween_property(self,"global_position",global_position - Vector2(0,6),0.25).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tw.parallel().tween_property(self,"modulate:a",1.0,0.125).set_ease(Tween.EASE_IN_OUT)

func set_ft(txt := "0"):
	lbl.text = str(txt)

var lapse := 0.0
func _process(delta):
	if active: lapse += delta
	if lapse > hold_time and active:
		kill()

func kill():
	active = false
	if tw: tw.kill()
	tw = create_tween()
	tw.tween_property(self,"modulate:a",0.0,0.125).set_ease(Tween.EASE_IN_OUT)
	await tw.finished
	queue_free()
