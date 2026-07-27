extends Control

@onready var close_menu = $PanelContainer/MarginContainer/VBoxContainer/CloseMenu

@onready var mv_up : Button = $PanelContainer/MarginContainer/VBoxContainer/mVolumeOption/mvUP
@onready var mv_down : Button = $PanelContainer/MarginContainer/VBoxContainer/mVolumeOption/mvDOWN
@onready var bgm_up : Button = $PanelContainer/MarginContainer/VBoxContainer/hbx/bgmVolumeOption/bgmUP
@onready var bgm_down : Button = $PanelContainer/MarginContainer/VBoxContainer/hbx/bgmVolumeOption/bgmDOWN
@onready var sv_up : Button = $PanelContainer/MarginContainer/VBoxContainer/hbx/sfxVolumeOption/svUP
@onready var sv_down : Button = $PanelContainer/MarginContainer/VBoxContainer/hbx/sfxVolumeOption/svDOWN
@onready var fs_left : Button = $PanelContainer/MarginContainer/VBoxContainer/hbx2/fsOption/fsLEFT
@onready var fs_right : Button = $PanelContainer/MarginContainer/VBoxContainer/hbx2/fsOption/fsRIGHT
@onready var scl_left : Button = $PanelContainer/MarginContainer/VBoxContainer/hbx2/sclOption/sclLEFT
@onready var scl_right : Button = $PanelContainer/MarginContainer/VBoxContainer/hbx2/sclOption/sclRIGHT
@onready var xp_up : Button = $PanelContainer/MarginContainer/VBoxContainer/expOption/xpUP
@onready var xp_down : Button = $PanelContainer/MarginContainer/VBoxContainer/expOption/xpDOWN

#@onready var window_settings = $PanelContainer/MarginContainer/VBoxContainer/hbx2

@onready var mv_val : RichTextLabel = $PanelContainer/MarginContainer/VBoxContainer/mVolumeOption/value/mc/mvVAL
@onready var bgm_val : RichTextLabel = $PanelContainer/MarginContainer/VBoxContainer/hbx/bgmVolumeOption/value/mc/bgmVAL
@onready var sfx_val : RichTextLabel = $PanelContainer/MarginContainer/VBoxContainer/hbx/sfxVolumeOption/value/mc/sfxVAL
@onready var fs_val : RichTextLabel = $PanelContainer/MarginContainer/VBoxContainer/hbx2/fsOption/value/mc/fsVAL
@onready var scl_val : RichTextLabel = $PanelContainer/MarginContainer/VBoxContainer/hbx2/sclOption/value/mc/sclVAL
@onready var xp_val : RichTextLabel = $PanelContainer/MarginContainer/VBoxContainer/expOption/value/mc/xpVAL

@onready var mvolbl : RichTextLabel = $PanelContainer/MarginContainer/VBoxContainer/mVolumeOption/lbl/mc/mvolbl
@onready var bgmolbl : RichTextLabel = $PanelContainer/MarginContainer/VBoxContainer/hbx/bgmVolumeOption/lbl/mc/bgmolbl
@onready var sfxolbl : RichTextLabel = $PanelContainer/MarginContainer/VBoxContainer/hbx/sfxVolumeOption/lbl/mc/sfxolbl
@onready var fsolbl : RichTextLabel = $PanelContainer/MarginContainer/VBoxContainer/hbx2/fsOption/lbl/mc/fxolbl
@onready var sclolbl : RichTextLabel = $PanelContainer/MarginContainer/VBoxContainer/hbx2/sclOption/lbl/mc/sclolbl
@onready var xpolbl : RichTextLabel = $PanelContainer/MarginContainer/VBoxContainer/expOption/lbl/mc/xpolbl

enum s {
	MASTER,
	BGM,
	SFX,
	WINDOW,
	SCALE,
	EXP,
}

var current : Control : 
	set(nv):
		current = nv
		focus_section()

var web : bool = false

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	web = OS.has_feature("web")
	AudioServer.set_bus_volume_db(0,linear_to_db(0.8))
	AudioServer.set_bus_volume_db(1,linear_to_db(0.8))
	AudioServer.set_bus_volume_db(2,linear_to_db(0.5))
	mv_val.text = str(int(roundf(AudioServer.get_bus_volume_linear(0) * 10.0)))
	bgm_val.text = str(int(roundf(AudioServer.get_bus_volume_linear(1) * 10.0)))
	sfx_val.text = str(int(roundf(AudioServer.get_bus_volume_linear(2) * 10.0)))
	fs_val.text = "0"
	scl_val.text = str(current_window_scale + 1,"x")
	xp_val.text = str(int(Dungeon.exp_mod),"x")
	
	close_menu.pressed.connect(exit)
	
	mv_up.pressed.connect(change_setting.bind(mv_up,s.MASTER,true))
	mv_down.pressed.connect(change_setting.bind(mv_down,s.MASTER,false))
	bgm_up.pressed.connect(change_setting.bind(bgm_up,s.BGM,true))
	bgm_down.pressed.connect(change_setting.bind(bgm_down,s.BGM,false))
	sv_up.pressed.connect(change_setting.bind(sv_up,s.SFX,true))
	sv_down.pressed.connect(change_setting.bind(sv_down,s.SFX,false))
	fs_left.pressed.connect(change_setting.bind(fs_left,s.WINDOW,true))
	fs_right.pressed.connect(change_setting.bind(fs_right,s.WINDOW,false))
	scl_left.pressed.connect(change_setting.bind(scl_left,s.SCALE,true))
	scl_right.pressed.connect(change_setting.bind(scl_right,s.SCALE,false))
	xp_up.pressed.connect(change_setting.bind(xp_up,s.EXP,true))
	xp_down.pressed.connect(change_setting.bind(xp_down,s.EXP,false))
	
	mv_up.mouse_entered.connect(show_tool_tip.bind(s.MASTER,true))
	mv_down.mouse_entered.connect(show_tool_tip.bind(s.MASTER,false))
	bgm_up.mouse_entered.connect(show_tool_tip.bind(s.BGM,true))
	bgm_down.mouse_entered.connect(show_tool_tip.bind(s.BGM,false))
	sv_up.mouse_entered.connect(show_tool_tip.bind(s.SFX,true))
	sv_down.mouse_entered.connect(show_tool_tip.bind(s.SFX,false))
	fs_left.mouse_entered.connect(show_tool_tip.bind(s.WINDOW,true))
	fs_right.mouse_entered.connect(show_tool_tip.bind(s.WINDOW,false))
	scl_left.mouse_entered.connect(show_tool_tip.bind(s.SCALE,true))
	scl_right.mouse_entered.connect(show_tool_tip.bind(s.SCALE,false))
	xp_up.mouse_entered.connect(show_tool_tip.bind(s.EXP,true))
	xp_down.mouse_entered.connect(show_tool_tip.bind(s.EXP,false))
	current = mv_up

var etw : Tween
var active := false
func enter():
	#Dungeon.AM.play(Symphony.SFX_p[Symphony.SFX.MENU_SEL],&"SFX",{AudioStreamArtist.prp.PITCH_RNG:Vector2(0.9,1.1)})
	if etw: etw.kill()
	get_tree().paused = true
	show()
	etw = create_tween()
	etw.tween_property(self,"offset_transform_position_ratio:y",0.0,0.25).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUAD)
	#etw.parallel().tween_property(self,"modulate:a",1.0,0.25).set_ease(Tween.EASE_IN_OUT)
	etw.tween_callback(func(): 
		active = true
		current = mv_up
		current.grab_focus()
		current.mouse_entered.emit()
	)

func exit():
	Dungeon.AM.play(Symphony.SFX_p[Symphony.SFX.MENU_BACK],&"SFX") #,{AudioStreamArtist.prp.PITCH_RNG:Vector2(0.9,1.1)}
	if etw: etw.kill()
	etw = create_tween()
	etw.tween_property(self,"offset_transform_position_ratio:y",-1.0,0.25).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUAD)
	#etw.parallel().tween_property(self,"modulate:a",0.0,0.25).set_ease(Tween.EASE_IN_OUT)
	etw.tween_callback(func(): 
		active = false
		get_tree().paused = false
		hide()
	)

func _process(_delta):
	if active: process_menu()
	if Input.is_action_just_pressed("pause_game") and !Dungeon.lss:
		match active:
			true: exit()
			false: enter()


func process_menu():
	if Input.is_action_just_pressed("jump"): exit()
	if Input.is_action_just_pressed("move_down") and current.focus_neighbor_bottom:
		current = current.get_node(current.get_focus_neighbor(SIDE_BOTTOM))
		current.grab_focus()
		current.mouse_entered.emit()
	if Input.is_action_just_pressed("move_up") and current.focus_neighbor_top:
		current = current.get_node(current.get_focus_neighbor(SIDE_TOP))
		current.grab_focus()
		current.mouse_entered.emit()
	if Input.is_action_just_pressed("move_left") and current.focus_neighbor_left:
		current = current.get_node(current.get_focus_neighbor(SIDE_LEFT))
		current.grab_focus()
		current.mouse_entered.emit()
	if Input.is_action_just_pressed("move_right") and current.focus_neighbor_right:
		current = current.get_node(current.get_focus_neighbor(SIDE_RIGHT))
		current.grab_focus()
		current.mouse_entered.emit()
	if Input.is_action_just_pressed("attack") and current:
		current.pressed.emit()
		await get_tree().process_frame
		current.grab_focus()

const FOCUS_COLOR := Color("639bff")
func focus_section():
	if current in [mv_down,mv_up]: mvolbl.add_theme_color_override("default_color",FOCUS_COLOR)
	else: mvolbl.add_theme_color_override("default_color",Color.WHITE)
	
	if current in [bgm_down,bgm_up]: bgmolbl.add_theme_color_override("default_color",FOCUS_COLOR)
	else: bgmolbl.add_theme_color_override("default_color",Color.WHITE)
	
	if current in [sv_down,sv_up]: sfxolbl.add_theme_color_override("default_color",FOCUS_COLOR)
	else: sfxolbl.add_theme_color_override("default_color",Color.WHITE)
	
	if current in [fs_left,fs_right]: fsolbl.add_theme_color_override("default_color",FOCUS_COLOR)
	else: fsolbl.add_theme_color_override("default_color",Color.WHITE)
	
	if current in [scl_left,scl_right]: sclolbl.add_theme_color_override("default_color",FOCUS_COLOR)
	else: sclolbl.add_theme_color_override("default_color",Color.WHITE)
	
	if current in [xp_down,xp_up]: xpolbl.add_theme_color_override("default_color",FOCUS_COLOR)
	else: xpolbl.add_theme_color_override("default_color",Color.WHITE)

var current_window_mode : int = 0
var current_window_scale : int = 2
const MAX_WIN_MODE : int = 3
const MAX_WIN_SCALE : int = 11
const MIN_WIN_SCALE : int = 1
const DEFAULT_WIN_SIZE := Vector2(576,324)
const MIN_WIN_SIZE := Vector2(192,108)
const MAX_EXP_MOD : int = 3
func change_setting(opt : Control, setting : s,mod : bool):
	current = opt
	match setting:
		s.MASTER:
			var nv := clampf(roundf(AudioServer.get_bus_volume_linear(0) * 10.0) + (1.0 if mod else -1.0),0,11)
			AudioServer.set_bus_volume_db(0,linear_to_db(nv/10.0))
			mv_val.text = str(int(roundf(AudioServer.get_bus_volume_linear(0) * 10.0)))
		s.BGM:
			var nv := clampf(roundf(AudioServer.get_bus_volume_linear(1) * 10.0) + (1.0 if mod else -1.0),0,11)
			AudioServer.set_bus_volume_db(1,linear_to_db(nv/10.0))
			bgm_val.text = str(int(roundf(AudioServer.get_bus_volume_linear(1) * 10.0)))
		s.SFX:
			var nv := clampf(roundf(AudioServer.get_bus_volume_linear(2) * 10.0) + (1.0 if mod else -1.0),0,11)
			AudioServer.set_bus_volume_db(2,linear_to_db(nv/10.0))
			sfx_val.text = str(int(roundf(AudioServer.get_bus_volume_linear(2) * 10.0)))
		s.WINDOW when !web:
			var nv := current_window_mode + (-1 if mod else 1)
			nv = absi(nv % MAX_WIN_MODE)
			current_window_mode = nv
			match current_window_mode:
				0: 
					get_window().content_scale_size = MIN_WIN_SIZE
					DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS,false)
					DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
					DisplayServer.window_set_size(DEFAULT_WIN_SIZE)
					get_window().position = Vector2i((DisplayServer.screen_get_size() - DisplayServer.window_get_size()) / 2.0)
				1: 
					DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
				2: 
					DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS,true)
			fs_val.text = str(current_window_mode)
		s.SCALE:
			var nv := current_window_scale + (-1 if mod else 1)
			nv = absi(nv % MAX_WIN_SCALE)
			current_window_scale = nv
			if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_WINDOWED and !web:
				DisplayServer.window_set_size(MIN_WIN_SIZE * (current_window_scale + 1))
				get_window().position = Vector2i((DisplayServer.screen_get_size() - DisplayServer.window_get_size()) / 2.0)
			else:
				get_window().content_scale_size = MIN_WIN_SIZE * (current_window_scale + 1)
			scl_val.text = str(current_window_scale + 1,"x")
			
		s.EXP:
			var nv := int(Dungeon.exp_mod) + (1 if mod else -1)
			nv = clampi(nv,1,MAX_EXP_MOD)
			Dungeon.exp_mod = float(nv)
			xp_val.text = str(int(Dungeon.exp_mod),"x")

@onready var ttlbl = $PanelContainer/MarginContainer/tt/mc/ttlbl
func show_tool_tip(setting : s,mod : bool):
	match setting:
		s.MASTER: ttlbl.text = "Master Volume Up" if mod else "Master Volume Down"
		s.BGM: ttlbl.text = "BGM Volume Up" if mod else "BGM Volume Down"
		s.SFX: ttlbl.text = "SFX Volume Up" if mod else "SFX Volume Down"
		s.WINDOW: ttlbl.text = "Change Window (Window, Full, Brdrless)"
		s.SCALE: ttlbl.text = "Decrease Game Scale" if mod else "Increase Game Scale"
		s.EXP: ttlbl.text = "Increase EXP Gain" if mod else "Decrease EXP Gain"
