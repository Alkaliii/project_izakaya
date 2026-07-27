extends AudioStreamPlayer
class_name AudioStreamArtist

# I have some extra functions to control myself easily
# That way you can create and control me dynamically!

enum prp { #for AM.play() settings
	VOLUME, #linear
	VOLUME_RNG, #linear
	PITCH,
	PITCH_RNG, #Vector2
	DELAY_PB, #Delays when the sound will play
	CALLBACK, #?
	FADE_IN, #float, starts the sound at 0 linear and fades it in using the time provided
	FADE_OUT, #float, checks the length to fade out to 0 linear in the time provided
}

static func auto_fade_out(asp : AudioStreamPlayer, t : float, n : float, on_finish : int = 0) -> void:
	# does not work with AudioStreamInteractive (no playback position)
	# does not work with AudioStreamGenerator/Microphone (indefinte length)
	# NOTE ASP must be playing before you call this, else it will quit out immediately and not perform the fade
	var length = asp.stream.get_length()
	while asp.playing:
		if (asp.get_playback_position() + AudioServer.get_time_since_last_mix()) > (length - t):
			#start fade
			fade_asp(asp,t,n,on_finish)
			break
		elif !asp.playing: break
		else:
			await Dungeon.frame_delay()

var mpaftw : Tween
func fade_music(t : float,n : float) -> void:
	#fade to n in time linearly
	if mpaftw: mpaftw.kill()
	mpaftw = self.create_tween()
	mpaftw.tween_property(self,"volume_linear",n,t)
	await mpaftw.finished

static func fade_asp(asp : AudioStreamPlayer, t : float, n: float, on_finish : int = 0) -> void:
	#fade to n in time linearly
	# on_finish = 0: do nothing
	# on_finish = 1: pause
	# on_finish = 2: stop
	# on_finish = 3: kill
	if asp.stream_paused: asp.stream_paused = false
	var tw : Tween = Dungeon.get_tree().create_tween()
	tw.tween_property(asp,"volume_linear",n,t)
	tw.tween_interval(0.2)
	await tw.finished
	match on_finish:
		0: return
		1: asp.stream_paused = true
		2: 
			asp.stop()
			asp.stream = null
		3: asp.queue_free()

func fade_and_pause_music(state : bool,t : float = 3.0) -> void:
	match state:
		true: #PAUSE
			await fade_music(t,0.0)
			pause_music_playback(state)
		false: #UNPAUSE
			pause_music_playback(state)
			await fade_music(t,1.0)

func fade_and_stop_music(t : float = 3.0) -> void:
	await fade_music(t,0.0)
	stop_music_playback()

func pause_music_playback(state : bool) -> void:
	set_stream_paused(state)

func stop_music_playback() -> void:
	stop()
	stream = null

var sstw : Tween
func swap_synchronized(sync : AudioStreamSynchronized, to_index : Array[int], in_time : float = 0.25):
	var already_swapped : Array[bool] = []
	for i in sync.stream_count:
		if db_to_linear(sync.get_sync_stream_volume(i)) > 0.0 and i in to_index:
			already_swapped.append(true)
		elif i in to_index:
			already_swapped.append(false)
			#print(db_to_linear(sync.get_sync_stream_volume(i))," ",to_index," ",i)
	if already_swapped.count(true) == to_index.size(): 
		#requested streams are already playing?
		print("already swapped to requested indexes")
		return
	#print(already_swapped," ",to_index.size())
	
	var oob = func(out_array : Array, i : int) -> Array:
		if i >= sync.stream_count: 
			out_array.append(i)
		return out_array
	var oob_result = to_index.reduce(oob,[])
	if oob_result.size() == to_index.size():
		print("all swap indices are out of bounds")
		return
	elif !oob_result.is_empty(): print("swap index ?",oob_result," is out of bounds")
	 
	#will set the volume of the specified indices to 1.0 and the rest to 0
	var mv = func(nv : float = 1.0,spec : Array[int] = []):
		if nv == null: return
		for i in sync.stream_count:
			if i in spec and db_to_linear(sync.get_sync_stream_volume(i)) < 1.1:
				sync.set_sync_stream_volume(i,linear_to_db(nv))
			elif db_to_linear(sync.get_sync_stream_volume(i)) > -0.1:
				sync.set_sync_stream_volume(i,linear_to_db(1.0-nv))
	
	if sstw: sstw.kill()
	sstw = create_tween()
	sstw.tween_method(mv.bind(to_index),0.0,1.0,in_time)
