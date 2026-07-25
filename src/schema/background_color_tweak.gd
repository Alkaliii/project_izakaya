@tool
extends Node2D


@export var background_color : Color = Color("303c82") : 
	set(nv):
		background_color = nv
		sky.color = background_color
@export var disable_fog : bool = false :
	set(nv):
		disable_fog = nv
		fog.visible = !disable_fog
@export var background_fog : GradientTexture1D : 
	set(nv):
		background_fog = nv
		fog.material.set_shader_parameter("color_gardient",background_fog)
@export var load_default_fog := true

@onready var sky : ColorRect = $CanvasLayer/Sky
@onready var fog : ColorRect = $CanvasLayer/Front/Fog

func _ready():
	if Engine.is_editor_hint():
		if !background_fog and load_default_fog:
			background_fog = load("res://assets/shaders/materials/default_background_fog_gradient.tres").duplicate_deep(Resource.DEEP_DUPLICATE_ALL)
	fog.visible = !disable_fog
