extends Node
# I AM THE SINGLETON!

static var AM : AudioManager

signal fairy_countdown(time_left : int)
signal set_cam_lim(lim : float,type : CameraLimit.t)
signal play_dialog(txt : String, nme : String,important : bool)
signal dialog_waiting()
signal end_dialog()
signal move_player(pos : Vector2, look : Vector2) # default inf
signal move_camera(t : ScriptLine.camera_tags,s : bool) #default to false
signal reset_camera() #all non player camera set priority to 0

var accumulated_exp : int = 0

func _ready():
	var newam := AudioManager.new()
	add_child(newam)
	AM = newam
	AM.play_music(await Symphony.get_music(Symphony.BGM.LEVEL))
	#print("Total to max level: ",get_total_exp())

func add_exp(gexp : int): accumulated_exp += gexp

const xpa : float = 0.1
const xpb : float = 1.9515
const xpc : float = 19.5
func get_level() -> int:
	var needed_exp : int = 0
	for lvl in 11:
		needed_exp += get_needed(lvl)
		if accumulated_exp > needed_exp: continue
		return lvl
	return 10

func get_needed(lvl : int) -> int: return int(ceilf(xpa * (pow(xpb,float(lvl))) + xpc))

func get_unused(lvl : int,earned : int) -> int:
	var total := accumulated_exp + earned
	for l in lvl:
		total -= get_needed(l)
	return total
	

func get_total_exp() -> int:
	var total_exp : int = 0
	for lvl in 11: total_exp += get_needed(lvl)
	return total_exp

const FLOAT_TEXT = preload("uid://c03wirrsk64x3")
func spawn_ft(pos : Vector2, txt : String, hold := 3.0):
	var new : FloatingText2D = FLOAT_TEXT.instantiate()
	new.hold_time = hold
	add_child(new)
	new.global_position = pos
	new.set_ft(txt)

func anykey(timeout := -1.0):
	var t : SceneTreeTimer
	if timeout > 0.0: t = get_tree().create_timer(timeout)
	while true:
		await frame_delay()
		if Input.is_anything_pressed(): 
			return true
		if t and t.time_left == 0.0: 
			t = null
			break
	return false

func delayRelease(action : StringName = "confirm", buffer : float = 0.125) -> void:
	#Input.is_anything_pressed() ??
	if Input.is_action_pressed(action):
		for i in 10000:
			if !Input.is_action_pressed(action):
				break
			await frame_delay()
	await time_delay(buffer)
	return

func multiDelayRelease(actions : Array[StringName] = ["confirm"], buffer : float = 0.125) -> void:
	for a in actions: if Input.is_action_pressed(a):
		for i in 10000:
			if !Input.is_action_pressed(a):
				break
			await frame_delay()
		break
	await time_delay(buffer)
	return

#multi input version takes an array of inputs?
func inputDelay(action : StringName = "confirm") -> bool:
	await time_delay(0.125)
	#show UI requesting player input (moving arrow)
	var input = false
	while !input:
		await frame_delay()
		if Input.is_action_just_pressed(action):
			input = true
			break
	return input

func multiInputDelay(actions : Array[StringName] = ["confirm"]) -> bool:
	await time_delay(0.125)
	#show UI requesting player input (moving arrow)
	var input = false
	while !input:
		await frame_delay()
		for action in actions:
			if Input.is_action_just_pressed(action):
				input = true
				break
	return input

func time_delay(t : float, process_always : bool = true,process_in_physics : bool = false,ignore_time_scale : bool = false):
	await get_tree().create_timer(t,process_always,process_in_physics,ignore_time_scale).timeout

func frame_delay():
	await get_tree().process_frame

func _load(file : String, return_loaded_file := false) -> Variant:
	file = ResourceUID.ensure_path(file)
	if !file.is_absolute_path(): 
		printerr("What the fuck is, ",file,"?")
		return
	if !return_loaded_file:
		#await _ls_anim(true)
		#await time_delay(1.0)
		pass
	var rldr := ResourceLoader
	rldr.load_threaded_request(file)
	
	var load_file : Resource #= load(file)
	var progress : Array = []
	var status : ResourceLoader.ThreadLoadStatus
	while true:
		await get_tree().process_frame
		status = rldr.load_threaded_get_status(file,progress)
		
		if status == ResourceLoader.THREAD_LOAD_LOADED:
			load_file = rldr.load_threaded_get(file)
			await get_tree().create_timer(0.2).timeout
			break
		elif status == ResourceLoader.THREAD_LOAD_FAILED:
			printerr("load failed")
			break
	
	if return_loaded_file: return load_file
	
	#Try and load packed scene immediately
	if load_file and load_file is PackedScene:
		var err := get_tree().change_scene_to_packed(load_file as PackedScene)
		if err != OK:
			printerr("Load Error, Critical Fail")
		
		while true:
			await get_tree().process_frame
			if get_tree().current_scene and get_tree().current_scene.is_node_ready():
				#await time_delay(1.0)
				#await _ls_anim(false)
				break
	
	return load_file




































# hi
