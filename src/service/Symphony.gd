extends Object
class_name Symphony

# I contain file paths to sound and keys for it

enum BGM {
	NONE,
	GRAVEYARD
}

const BGM_p : Dictionary[BGM,String] = {
	BGM.NONE:"",
	BGM.GRAVEYARD:"uid://cmkhwa3roivnw"
}

enum SFX {
	NONE,
	LEVEL_UP,
	FAIRY_SPELL,
	ENEMY_HIT,
	PLAYER_HIT,
	PLAYER_HEAL,
	PLAYER_JUMP,
	PLAYER_LAND,
}

const SFX_p : Dictionary[SFX,String] = {
	SFX.NONE:"",
	SFX.LEVEL_UP:"uid://d071pwi5u3otf",
	SFX.FAIRY_SPELL:"uid://bxvx07qtw02rp",
	SFX.ENEMY_HIT:"uid://cxe56n5liemah",
	SFX.PLAYER_HIT:"uid://c1wmixry68mu0",
	SFX.PLAYER_HEAL:"uid://xrapl8rdgl8n",
	SFX.PLAYER_JUMP:"uid://4cn2f21vme1j",
	SFX.PLAYER_LAND:"uid://drcs41l7hixns",
}

static func get_music(music : Symphony.BGM) -> AudioStream:
	var M : AudioStream = await Dungeon._load(Symphony.BGM_p[music],true)
	return M

static func fuse_music(music : Array[Symphony.BGM]) -> AudioStreamInteractive:
	# create new ASI with music passed in
	var ASI : AudioStreamInteractive = AudioStreamInteractive.new()
	
	#setup ASI
	#set clips (clips will be set to advance to the next clip avalible in the array)
	var idx := 0
	for i in music:
		ASI.clip_count += 1
		var loadm = await Dungeon._load(Symphony.BGM_p[i],true) #load(Symphony.BGM_p[i])
		var clip_index = idx
		var clip_name = str(Symphony.BGM_p[i]).get_file().replace(str(Symphony.BGM_p[i]).get_extension(),"")
		ASI.set_clip_stream(clip_index,loadm)
		ASI.set_clip_name(clip_index,clip_name)
		idx += 1
	
	#set auto advance &
	#set transitions (clips will use auto transitions)
	for i in ASI.clip_count:
		var next_clip := (i + 1) % ASI.clip_count
		if !AudioManager.does_stream_loop(ASI.get_clip_stream(i)):
			ASI.set_clip_auto_advance(i,AudioStreamInteractive.AUTO_ADVANCE_ENABLED)
			ASI.set_clip_auto_advance_next_clip(i,next_clip)
			ASI.add_transition(i,next_clip,
			AudioStreamInteractive.TRANSITION_FROM_TIME_END,
			AudioStreamInteractive.TRANSITION_TO_TIME_START,
			AudioStreamInteractive.FADE_AUTOMATIC,2
			)
	
	return ASI

static func sync_music(music : Array[AudioStream],inital_track : int = 0) -> AudioStreamSynchronized:
	var ASS : AudioStreamSynchronized = AudioStreamSynchronized.new()
	
	#setup ASS
	#set streams
	var idx : int = 0
	for i in music:
		ASS.stream_count += 1
		ASS.set_sync_stream(idx,i)
		idx += 1
	
	#Auto set inital spec to 1.0 and rest to nothing
	for i in ASS.stream_count:
		if i == inital_track:
			ASS.set_sync_stream_volume(i,linear_to_db(1.0))
		else:
			ASS.set_sync_stream_volume(i,linear_to_db(0.0))
	
	return ASS

#loading function should be builtin...
