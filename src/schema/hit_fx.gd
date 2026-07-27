extends Node2D
class_name BasicHitFx

@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var sparkles_explode = $SparklesExplode
@onready var spark = $ColorRect

func _ready():
	animated_sprite_2d.hide()
	playing = false
	spark.hide()
	animated_sprite_2d.hide()
	spark.material.set_shader_parameter("progress",0.0)

func restart(sev : int,flip := false):
	if tw: tw.kill()
	playing = false
	spark.hide()
	animated_sprite_2d.hide()
	spark.material.set_shader_parameter("progress",0.0)
	play(sev,flip)

var playing := false
var tw : Tween
func play(sev : int,flip := false):
	if playing: return
	sev = clampi(sev,-1,2)
	tw = create_tween()
	var spark_sz := 1.0
	var show_sparkles := false
	match sev:
		-1:
			spark_sz = 0.0
			show_sparkles = false
		0:
			spark_sz = 0.5
			show_sparkles = false
		1:
			spark_sz = 1.0
			show_sparkles = false
		2: #crit
			spark_sz = 1.0
			show_sparkles = true
	spark.show()
	spark.offset_transform_rotation = randf_range(-TAU,TAU)
	tw.tween_property(spark.material,"shader_parameter/progress",spark_sz,0.1).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
	tw.tween_property(spark.material,"shader_parameter/progress",0.0,0.05).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_EXPO)
	tw.tween_callback(func():
		animated_sprite_2d.flip_h = flip
		animated_sprite_2d.show()
		animated_sprite_2d.play("default")
		if show_sparkles: sparkles_explode.restart()
	)
	tw.tween_callback(func():
		spark.hide()
		await animated_sprite_2d.animation_finished
		animated_sprite_2d.hide()
		playing = false
	)
	#animated_sprite_2d.play("default")
