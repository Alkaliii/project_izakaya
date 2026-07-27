extends Node
class_name AudioManager

var num_players := 8

var available : Array[AudioStreamPlayer] = []
var queue_sound = []
var queue_bus = []
var queue_settings : Array[Dictionary] = []

#Music
var currently_playing : Array[Symphony.BGM] = [Symphony.BGM.NONE]
var music_player : AudioStreamArtist
var music_player_b : AudioStreamArtist
#var noise_player : AudioStreamArtist


func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	music_player = AudioStreamArtist.new()
	add_child(music_player)
	music_player.bus = &"BGM"
	
	music_player_b = AudioStreamArtist.new()
	add_child(music_player_b)
	music_player_b.bus = &"BGM"
	music_player_b.fade_music(0.25,0.0)
	
	#noise_player = AudioStreamArtist.new()
	#add_child(noise_player)
	#noise_player.bus = &"BGMACC"
	#noise_player.fade_music(0.25,0.0)
	
	for i in num_players:
		var p = AudioStreamPlayer.new()
		#var m = AudioStreamPlayer.new()
		add_child(p)
		#add_child(m)
		available.append(p)
		#available_music_stream.append(m)
		p.finished.connect(_stream_finished.bind(p))

func _stream_finished(stream):
	available.append(stream)

func play(sound_path,bus = "master",settings := {}):
	queue_sound.append(ResourceUID.ensure_path(sound_path))
	queue_bus.append(bus)
	queue_settings.append(settings)

func clean_players():
	if available.size() > num_players:
		var kill = available.pop_back()
		remove_child(kill)
		kill.queue_free()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	#play sound
	if !queue_sound.is_empty() and !available.is_empty():
		available[0].stream = load(queue_sound.pop_front())
		available[0].bus = queue_bus.pop_front()
		#available[0].play()
		apply_settings(available.pop_front(),queue_settings.pop_front())
	#play sound on a temp new
	elif !queue_sound.is_empty() and available.is_empty():
		var np = AudioStreamPlayer.new()
		add_child(np)
		np.finished.connect(_stream_finished.bind(np))
		np.stream = load(queue_sound.pop_front())
		np.bus = queue_bus.pop_front()
		apply_settings(np,queue_settings.pop_front())
		#np.play()
	elif queue_sound.is_empty() and !available.is_empty():
		clean_players()

func apply_settings(asp : AudioStreamPlayer, setting : Dictionary):
	#Volume
	if setting.has(AudioStreamArtist.prp.VOLUME):
		asp.volume_linear = setting[AudioStreamArtist.prp.VOLUME]
	if setting.has(AudioStreamArtist.prp.VOLUME_RNG):
		var vrng : Vector2 = setting[AudioStreamArtist.prp.VOLUME_RNG]
		asp.volume_linear = randf_range(vrng.x,vrng.y)
	if !setting.has(AudioStreamArtist.prp.VOLUME) and !setting.has(AudioStreamArtist.prp.VOLUME_RNG):
		asp.volume_linear = 1.0
	
	#Pitch
	if setting.has(AudioStreamArtist.prp.PITCH):
		asp.pitch_scale = setting[AudioStreamArtist.prp.PITCH]
	if setting.has(AudioStreamArtist.prp.PITCH_RNG):
		var prng : Vector2 = setting[AudioStreamArtist.prp.PITCH_RNG]
		asp.pitch_scale = randf_range(prng.x,prng.y)
	if !setting.has(AudioStreamArtist.prp.PITCH) and !setting.has(AudioStreamArtist.prp.PITCH_RNG):
		asp.pitch_scale = 1.0
	
	#Callback
	if setting.has(AudioStreamArtist.prp.CALLBACK):
		setting[AudioStreamArtist.prp.CALLBACK].call(asp)
	
	var fade_in := false
	if setting.has(AudioStreamArtist.prp.FADE_IN):
		fade_in = true
		asp.volume_linear = 0.0
	
	var fade_out := false
	if setting.has(AudioStreamArtist.prp.FADE_OUT):
		fade_out = true
	
	#Delay
	if setting.has(AudioStreamArtist.prp.DELAY_PB):
		await time_delay(setting[AudioStreamArtist.prp.DELAY_PB])
		asp.play()
	else:
		asp.play()
	
	if fade_in:
		AudioStreamArtist.fade_asp(asp,setting[AudioStreamArtist.prp.FADE_IN],1.0,0)
	if fade_out:
		AudioStreamArtist.auto_fade_out(asp,setting[AudioStreamArtist.prp.FADE_OUT],0.0,0)

func apply_bus_effect(bus : StringName,effect : AudioEffect = null,new := false, extra : Dictionary = {}):
	#use new to add an additional effect ontop
	var bus_idx = AudioServer.get_bus_index(bus)
	if !effect or effect == null:
		#remove effect
		AudioServer.remove_bus_effect(bus_idx,0)
		return
	
	#remove existing
	var fxcount = AudioServer.get_bus_effect_count(bus_idx)
	if fxcount != 0 and (!new):
		var fxrnge = range(fxcount)
		fxrnge.reverse()
		for i in fxrnge:
			AudioServer.remove_bus_effect(bus_idx,i)
	
	#add effect
	AudioServer.add_bus_effect(bus_idx,effect)

func fade_music(t : float, n : float):
	#Auto fades a or b if they have a stream
	if music_player.stream: music_player.fade_music(t,n) #fade_music_a(t,n)
	if music_player_b.stream: music_player_b.fade_music(t,n) #fade_music_b(t,n)
	await time_delay(t)

#var mpaftw : Tween
#func fade_music_a(t : float,n : float):
	##fade to n in time linearly
	#if mpaftw: mpaftw.kill()
	#mpaftw = get_tree().create_tween()
	#mpaftw.tween_property(music_player,"volume_linear",n,t)
	#await mpaftw.finished
#
#var mpbftw : Tween
#func fade_music_b(t : float,n : float):
	##fade to n in time linearly
	#if mpbftw: mpbftw.kill()
	#mpbftw = get_tree().create_tween()
	#mpbftw.tween_property(music_player_b,"volume_linear",n,t)
	#await mpbftw.finished

func fade_and_pause_music(state : bool,t : float = 3.0):
	if music_player.stream_paused != state: music_player.fade_and_pause_music(state,t) #fade_and_pause_music_a(state,t)
	if music_player_b.stream_paused != state: music_player_b.fade_and_pause_music(state,t) #fade_and_pause_music_b(state,t)
	await time_delay(t)

#func fade_and_pause_music_a(state : bool,t : float = 3.0):
	#match state:
		#true: #PAUSE
			#await fade_music_a(t,0.0)
			#music_player.set_stream_paused(state)
		#false: #UNPAUSE
			#music_player.set_stream_paused(state)
			#await fade_music_a(t,1.0)
#
#func fade_and_pause_music_b(state : bool,t : float = 3.0):
	#match state:
		#true: #PAUSE
			#await fade_music_b(t,0.0)
			#music_player_b.set_stream_paused(state)
		#false: #UNPAUSE
			#music_player_b.set_stream_paused(state)
			#await fade_music_b(t,1.0)

func fade_and_stop_music(t : float = 3.0):
	if music_player.playing: music_player.fade_and_stop_music(t) #fade_and_stop_music_a(t)
	if music_player_b.playing: music_player_b.fade_and_stop_music(t) #fade_and_stop_music_b(t)
	await time_delay(t)
	set_currently_playing([])

#func fade_and_stop_music_a(t : float = 3.0):
	#await fade_music_a(t,0.0)
	#music_player.stop()
	#music_player.stream = null
#
#func fade_and_stop_music_b(t : float = 3.0):
	#await fade_music_b(t,0.0)
	#music_player_b.stop()
	#music_player_b.stream = null

func is_currently_playing(qcp : Array[Symphony.BGM]) -> bool: #query currently playing
	for l in qcp:
		if currently_playing.has(l): return true
	return false

func set_currently_playing(ncp : Array[Symphony.BGM], add := false): #new currently playing
	if add: currently_playing.append_array(ncp)
	else:
		currently_playing.clear()
		currently_playing = ncp

func swap_music(idx : Array[int] = [], tt : float = 0.25) -> bool:
	if idx.is_empty(): return false
	var ret := false
	if music_player.stream is AudioStreamSynchronized and music_player.playing:
		music_player.swap_synchronized(music_player.stream,idx,tt)
		ret = true
	if music_player_b.stream is AudioStreamSynchronized and music_player_b.playing:
		music_player_b.swap_synchronized(music_player_b.stream,idx,tt)
		ret = true
	return ret

var automating_current := false
func play_music(music : AudioStream,tt : Vector3 = Vector3(1.0,1.0,-1.0),extra_settings : Dictionary = {}):
	var new_volume : float
	if tt.z == -1: new_volume = music_player.volume_linear
	else: new_volume = tt.z
	if music_player.stream == music and music_player.playing and !automating_current:
		#this only works with prefused streams I think
		print("Ignoring Repeat Music Call")
		return
	# Turns off music player
	if music_player.playing:
		#await fade_music(tt.x,0.0)
		automating_current = true
		await fade_and_stop_music(tt.x)
		automating_current = false
	else: music_player.volume_linear = 0.0
	
	#set new stream and play
	music_player.stream = music
	music_player.play()
	music_player.fade_music(tt.y,new_volume)
	#await fade_music_a(tt.y,1.0)

#make some sorta generic cross function
func play_battle_music(music : Array[Symphony.BGM], t : float, extra_settings : Dictionary = {}): #noise : Symphony.BGM
	#begin playing noise (loop)
	#will transition mp to 0 in time specified
	#will transition mpb to 1 in time specified
	
	# create new ASI with music passed in
	var ASI : AudioStreamInteractive = AudioStreamInteractive.new()
	
	#set noise
	#var loadn = await Pearlessential._load(Symphony.BGM_p[noise])
	#noise_player.stream = loadn
	#noise_player.play()
	
	#setup ASI
	#set clips (clips will be set to advance to the next clip avalible in the array)
	var idx := 0
	for i in music:
		ASI.clip_count += 1
		# TODO Consider writing an interactive loader function thats threaded since the game freeze on first time load
		var loadm = await _load(Symphony.BGM_p[i],true) #load(Symphony.BGM_p[i])
		var clip_index = idx
		var clip_name = str(Symphony.BGM_p[i]).get_file().replace(str(Symphony.BGM_p[i]).get_extension(),"")
		ASI.set_clip_stream(clip_index,loadm)
		ASI.set_clip_name(clip_index,clip_name)
		idx += 1
	
	#set auto advance &
	#set transitions (clips will use auto transitions)
	for i in ASI.clip_count:
		var next_clip := (i + 1) % ASI.clip_count
		if !does_stream_loop(ASI.get_clip_stream(i)):
			ASI.set_clip_auto_advance(i,AudioStreamInteractive.AUTO_ADVANCE_ENABLED)
			ASI.set_clip_auto_advance_next_clip(i,next_clip)
			ASI.add_transition(i,next_clip,
			AudioStreamInteractive.TRANSITION_FROM_TIME_END,
			AudioStreamInteractive.TRANSITION_TO_TIME_START,
			AudioStreamInteractive.FADE_AUTOMATIC,2
			)
	
	music_player_b.stream = ASI
	
	#start transition
	music_player.fade_and_pause_music(true,t) #pause A in time
	#noise_player.fade_music(t,0.5)
	music_player_b.play()
	music_player_b.fade_music(t,1.0)
	#play(Symphony.BGM_p[Symphony.BGM.BattleReverseCrash],"BGM")

#func play_battle_music_transition(early : bool = false):
	##swaps properly
	#
	##if players aren't at volume it will expidite it (0.5 secs)
	#if early and !music_player.stream_paused:
		#music_player.fade_and_pause_music(true,0.5)
		#music_player_b.fade_and_pause_music(false,0.5)
		#await Pearlessential.timeDelay(0.5)
	#
	##1. play reverse clash and fadeout noise for 2 seconds
	##await Pearlessential.timeDelay(1.0)
	#noise_player.fade_and_stop_music(0.8)
	#
	##2. play normal clash and switch to battle theme
	##await Pearlessential.timeDelay(1.0)
	#music_player_b.play()
	#music_player_b.fade_music(0.8,1.0)
	##play(Symphony.BGM_p[Symphony.BGM.BattleCrash],"BGM")

func end_battle_music():
	#restores normal music (step outta circle)
	#noise_player.fade_and_stop_music(0.5)
	music_player_b.fade_and_stop_music(0.5)
	music_player.fade_and_pause_music(false,0.5)
	#will transition mp to 1 in 0.5 secs
	#will transition mpb to 0 in 0.5 secs
	pass

static func does_stream_loop(s : AudioStream) -> bool:
	if s is AudioStreamOggVorbis: return s.loop
	if s is AudioStreamMP3: return s.loop
	if s is AudioStreamWAV: return bool(s.loop_mode)
	if s is AudioStreamPlaylist: return s.loop
	
	return false

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
