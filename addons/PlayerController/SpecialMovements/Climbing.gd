@tool
extends SpecialMovementsPlatformer2D
class_name ClimbLadder

## Override commands and animations.
## Example:
## requiredCommands = PackedStringArray(["dash"])
## requiredAnimations = PackedStringArray(["dash"])
func _set_commands_and_animations() -> void:
	# This name is shown in the debug menu. Replace it to fit your needs
	movementName = "ClimbLadder"
	#requiredCommands = PackedStringArray(["climb","drop"])
	requiredAnimations = PackedStringArray(["climbing"])

## Setup function.
func _on_update() -> void:
	pass

## Animation check function. If you need to change animations do it here mainly.
#var anim_playing := false
func _animation_check() -> void:
	if _get_special_flag("climbing_ladder") and parent.commandInputs.up.hold:
		parent.play_animation("climbing")
	elif _get_special_flag("climbing_ladder") and !parent.commandInputs.up.hold: 
		parent.play_animation("climbing",0.0)

## Special gravity function. Apply any needed changes to the gravity here. parent.appliedValues.gravity and parent.appliedValues.terminalVelocity changes go here.
func _gravity() -> void:
	if parent.commandInputs.up.hold and _get_special_flag("climbing_ladder"):
		parent.appliedValues.gravity = 0.0
	elif _get_special_flag("climbing_ladder"):
		parent.appliedValues.gravity = 0.0

## Movement check function. The main component of this. Check for inputs with parent.commandInputs.<your_input>.<tap/hold/release>
func _movement_check() -> void:
	if parent.playerSprite.animation == "jump": return
	if _get_special_flag("block_ladder"): 
		_set_special_flag("climbing_ladder",false)
		return
	if parent.commandInputs.up.hold and _get_special_flag("near_ladder"):
		if _get_special_flag("attacking"): return
		#print("climbs")
		_set_special_flag("climbing_ladder",true,["jumpAnimation","moveAnimation","move"])
		#parent.play_animation("climbing")
	if parent.commandInputs.up.hold and _get_special_flag("climbing_ladder"):
		parent.velocity.y = -50
	elif _get_special_flag("climbing_ladder"):
		parent.velocity.y = 0.0
	if (parent.commandInputs.down.tap or parent.commandInputs.jump.tap or !_get_special_flag("near_ladder")) and _get_special_flag("climbing_ladder"):
		_set_special_flag("climbing_ladder",false)
		if parent.commandInputs.jump.tap: parent._jump(true)

## Jump override function. If you need a custom jump function it goes here. Return true if you applied changes to override usual jump behavior, return false otherwise.
func _jump_override() -> bool:
	return false

## Sprite flip check function. Return true if you need the sprite to not flip under certain circumstances.
func _flip_check() -> bool:
	#if parent.commandInputs.up.hold and _get_special_flag("climbing_ladder"): return true
	return false

### Exports variables for debug testing live.
#func _get_debug_variables() -> DebugMenuEditor.ParameterCategory:
	#var category: DebugMenuEditor.ParameterCategory = DebugMenuEditor.ParameterCategory.new()
	#category.category = movementName
	#category.contents = [
		## Add contents following the formula:
		## parameter is the name of the variable as is in this script
		## type is the type of variable to use. Your pick from NUMERIC, BOOL, LIST.
		## defaultValue should be set to whatever the default value is. Unless there's extra steps involved you can simply put the variable you are exposing here.
		## extra data is used for NUMERIC and LIST types only:
		## NUMERIC extra data is a DebugParameterContainer.NumericData containing min_value, max_value, and step.
		## You can crate it using DebugParameterContainer.NumericData.new(min_value, max_value, step)
		## LIST extra data is an array of Strings to show in the list component.
		## Sample line:
		## DebugMenuEditor.ParameterContents.new(parameter: String, type: DebugParameterContainer.ParameterTypes, defaultValue: Variant, extraData: Variant)
		## Please check other included movement types for more examples of this being used.
	#]
	#return category

## What to do when the values are updated through debug.
func _on_debug_update() -> void:
	pass
