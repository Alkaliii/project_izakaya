extends Control

@onready var player_sprite = $MarginContainer/Control/PlayerSprite
@onready var fairy_sprite = $MarginContainer/Control/FairySprite

#@onready var player_sprite = $SubViewportContainer/SubViewport/MarginContainer/Control/PlayerSprite
#@onready var fairy_sprite = $SubViewportContainer/SubViewport/MarginContainer/Control/FairySprite
#@onready var sub_viewport_container = $SubViewportContainer


func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS

var tw : Tween
func enter():
	Dungeon.AM.fade_and_stop_music()
	get_tree().paused = true
	if tw: tw.kill()
	tw = create_tween()
	show()
	player_sprite.play("walk")
	fairy_sprite.play("fly")
	#tw.tween_property(sub_viewport_container.material,"shader_parameter/progress",1.0,0.25).set_ease(Tween.EASE_IN_OUT)
	tw.tween_property(self,"modulate:a",1.0,0.25).set_ease(Tween.EASE_IN_OUT)
	await tw.finished

func exit():
	get_tree().paused = false
	if tw: tw.kill()
	tw = create_tween()
	#tw.tween_property(sub_viewport_container.material,"shader_parameter/progress",0.0,0.25).set_ease(Tween.EASE_IN_OUT)
	tw.tween_property(self,"modulate:a",0.0,0.25).set_ease(Tween.EASE_IN_OUT)
	#tw.tween_callback(func():)
	await tw.finished
	player_sprite.stop()
	fairy_sprite.stop()
	hide()
