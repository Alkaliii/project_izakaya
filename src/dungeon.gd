extends Node
# I AM THE SINGLETON!

static var AM : AudioManager

signal fairy_countdown(time_left : int)

func _ready():
	var newam := AudioManager.new()
	add_child(newam)
	AM = newam
	AM.play_music(await Symphony.get_music(Symphony.BGM.GRAVEYARD))

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
