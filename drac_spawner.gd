extends Node2D


var time : int = 10

func _ready():
	time = randi_range(8280,10000)

const BOSS_ENEMY = preload("uid://cu4aryopu4mug")

func _process(delta):
	time -= delta
	Dungeon.dtime.emit(humanize_seconds(time))
	if time <= 0:
		set_process(false)
		var new : CountDOwen = BOSS_ENEMY.instantiate()
		new.attack_only = true
		new.global_position = global_position
		add_child(new)
		Dungeon.dtime.emit("[shake rate=20 level=6]"+humanize_seconds(time))

func humanize_seconds(seconds : float) -> String:
	var mn = int(seconds / 60) % 60 #fmod(playtime, 3600) / 60
	var hrs = int(seconds / 3600) #fmod(playtime, 216000) / 60 / 24 #12960000
	var str_elapsed = "%02d:%02d" % [hrs, mn]
	return str_elapsed
