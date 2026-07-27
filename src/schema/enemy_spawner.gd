extends Node2D


@export var extents : Rect2i = Rect2i(-5,5,-5,5) #cells
@export var primary : PackedScene #60
@export var secondary : PackedScene #40 if assigned
@export var max_spawn := 4

var current_spawns : Array[BaseEnemy2D] = []
@onready var check = $Check
@onready var sprite_2d = $Sprite2D

func _ready():
	if !primary: set_process(false)
	sprite_2d.hide()

func _process(_delta):
	if current_spawns.size() != max_spawn and !gen_cooldown:
		generate()
	if gen_cooldown and gen_cooldown.time_left == 0.0:
		gen_cooldown = null

var gen_cooldown : SceneTreeTimer
func generate():
	gen_cooldown = get_tree().create_timer(0.25)
	
	var sx := randi_range(extents.position.x,extents.position.y)
	var sy := randi_range(extents.size.x,extents.size.y)
	var spos : Vector2
	var tried_left : bool = false
	var tried_right : bool = false
	var tried_up : bool = false
	var tried_down : bool = false
	for i in 30:
		spos = Vector2(sx,sy) * 16.0
		check.global_position = global_position + spos
		check.force_shapecast_update()
		if check.is_colliding():
			if tried_up and tried_down and tried_left and tried_right:
				Toolkitu.logm("Failed to spawn enemy!",Toolkitu.ll.ERROR,"",{"0":"Couldn't find spawn position."})
				return
			if sx < maxi(extents.position.x,extents.position.y): 
				sx += 1
				continue
			else: tried_right = true
			if sx > mini(extents.position.x,extents.position.y): 
				sx -= 1
				continue
			else: tried_left = true
			if tried_left and tried_right:
				if sy < maxi(extents.size.x,extents.size.y):
					tried_left = false
					tried_right = false
					sy += 1
					continue
				else: tried_up = true
				if sy > mini(extents.size.x,extents.size.y):
					tried_left = false
					tried_right = false
					sy -= 1
					continue
				else: tried_down = true
		else: break
	
	var which = primary
	if randf() < 0.4 and secondary: which = secondary
	var new : BaseEnemy2D = which.instantiate()
	if [true,false,false].pick_random(): new.bonus_health += randi_range(1,3)
	add_child(new)
	new.global_position = global_position + spos
	new.im_dead.connect(clean_spawns.bind(new))
	current_spawns.append(new)
	gen_cooldown = get_tree().create_timer(randf_range(2.0,5.0))

func clean_spawns(d : BaseEnemy2D):
	current_spawns.erase(d)
