extends Object
class_name Symphony

# I contain file paths to sound and keys for it

enum BGM {
	NONE,
	GRAVEYARD,
	TITLE,
	LEVEL,
	BOSS,
	BOSS_B,
}

const BGM_p : Dictionary[BGM,String] = {
	BGM.NONE:"",
	BGM.GRAVEYARD:"uid://cmkhwa3roivnw",
	BGM.TITLE:"uid://dqgi4hweps6fg",
	BGM.LEVEL:"uid://b6cenvig34xo2",
	BGM.BOSS:"uid://sbtkl0in74ik",
	BGM.BOSS_B:"uid://cydx1omi2teh0",
}

enum SFX {
	NONE,
	COUNTDOWN,
	LEVEL_UP,
	FAIRY_SPELL,
	FAIRY_HIT,
	ENEMY_HIT,
	PLAYER_HIT,
	PLAYER_HEAL,
	PLAYER_JUMP,
	PLAYER_LAND,
	PLAYER_DEFEAT,
	ENEMY_ATTACK_A,
	ENEMY_ATTACK_B,
	BOSS_APPEAR,
	MENU_BACK,
	MENU_SEL,
}

const SFX_p : Dictionary[SFX,String] = {
	SFX.NONE:"",
	SFX.COUNTDOWN:"uid://b7yskpol27psj",
	SFX.LEVEL_UP:"uid://d071pwi5u3otf",
	SFX.FAIRY_SPELL:"uid://bxvx07qtw02rp",
	SFX.FAIRY_HIT:"uid://beabuf51ppusv",
	SFX.ENEMY_HIT:"uid://cxe56n5liemah",
	SFX.PLAYER_HIT:"uid://c1wmixry68mu0",
	SFX.PLAYER_HEAL:"uid://xrapl8rdgl8n",
	SFX.PLAYER_JUMP:"uid://4cn2f21vme1j",
	SFX.PLAYER_LAND:"uid://drcs41l7hixns",
	SFX.PLAYER_DEFEAT:"uid://dgs2osuwqpckx",
	SFX.ENEMY_ATTACK_A:"uid://cod778lds68gm",
	SFX.ENEMY_ATTACK_B:"uid://bw5b34vqccj6",
	SFX.BOSS_APPEAR:"uid://nmikean3kuax",
	SFX.MENU_BACK:"uid://dqxf38n021pc1",
	SFX.MENU_SEL:"uid://djinaj3l46pvg",
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
