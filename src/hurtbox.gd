@tool
extends Area2D
class_name Hurtbox2D


@export var ignore_box_tags : Array[Hitbox2D.tags] = []

signal detected(state : bool,tag : Hitbox2D.tags)

func _init():
	set_collision_layer_value(1,false)
	set_collision_layer_value(7,true)
	set_collision_mask_value(1,false)
	set_collision_mask_value(6,true)


func _ready():
	area_entered.connect(oa_enter)
	area_exited.connect(oa_exit)

func _process(delta):
	#if
	pass 

var _detected_areas : Array[Area2D] = []
func oa_enter(area : Area2D):
	_detected_areas.append(area)
	if area is Hitbox2D and area.box_tag in ignore_box_tags: return
	elif area is Hitbox2D: detected.emit(true,area.box_tag)

func oa_exit(area : Area2D):
	_detected_areas.erase(area)
	if area is Hitbox2D and area.box_tag in ignore_box_tags: return
	elif area is Hitbox2D: detected.emit(false,area.box_tag)
