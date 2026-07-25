extends Node2D
class_name CameraLimit

enum t {
	LEFT,
	RIGHT,
	BOTTOM,
}
@export var type : t = t.LEFT


func _ready():
	var lim : float
	match type:
		t.LEFT, t.RIGHT: lim = global_position.x
		t.BOTTOM: lim = global_position.y
	Dungeon.set_cam_lim.emit(lim,type)
	hide()
