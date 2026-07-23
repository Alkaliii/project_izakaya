@tool
extends SpecialMovementsPlatformer2D
class_name Attack

## Override commands and animations.
## Example:
func _set_commands_and_animations() -> void:
	# This name is shown in the debug menu. Replace it to fit your needs
	movementName = "Attack"
	requiredCommands = PackedStringArray(["attack"])
	requiredAnimations = PackedStringArray(["attack","jump_attack"])

## Setup function.
func _on_update() -> void:
	#if _get_special_flag("attacking"):
		#if parent.velocity.y > 0.0: 
			#var block : PackedStringArray = PackedStringArray(["move","moveAnimation","jumpAnimation","jump"])
			#_set_special_flag("attacking", true, block)
	pass

## Animation check function. If you need to change animations do it here mainly.
func _animation_check() -> void:
	if _get_special_flag("attacking"):
		if parent.is_on_floor():
			parent.play_attack_animation()
			#parent.playerSprite.offset.x = -8.0 if parent.playerSprite.flip_h else 8.0
		else: parent.play_animation("jump_attack")

## Special gravity function. Apply any needed changes to the gravity here. parent.appliedValues.gravity and parent.appliedValues.terminalVelocity changes go here.
func _gravity() -> void:
	#if _get_special_flag("attacking"):
		#parent.appliedValues.gravity = 0.0
	pass

## Movement check function. The main component of this. Check for inputs with parent.commandInputs.<your_input>.<tap/hold/release>
func _movement_check() -> void:
	if parent.commandInputs.attack.tap and !parent.is_on_wall() and !_get_special_flag("attacking"):
		var block : PackedStringArray = PackedStringArray(["moveAnimation","jumpAnimation","jump","move_half"])
		#if parent.is_on_floor() and parent.velocity.y > 0.0 and !Input.is_action_just_pressed("jump"): 
			#print("blocking ",parent.is_on_floor()," ",is_zero_approx(parent.velocity.y)," ",parent.velocity.y > 0.0)
			#block.append("move")
		_set_special_flag("attacking", true, block)
		parent.attack.emit(true)
		if parent.is_on_floor() and parent.velocity.y >= 0.0: await parent.play_attack_animation()
		else: await parent.playerSprite.animation_finished
		parent.attack.emit(false)
		_set_special_flag("attacking", false)
		#parent.playerSprite.offset.x = 0.0
	#if _get_special_flag("attacking"):
		#if parent.velocity.y > 1.0 or parent.velocity.y < 1.0:
			#_set_special_flag("attacking", true, ["move","moveAnimation", "jumpAnimation"])
			##print("stop move")
			##parent.velocity = Vector2.ZERO
		#else:
			#_set_special_flag("attacking", true, ["moveAnimation", "jumpAnimation"])

## Jump override function. If you need a custom jump function it goes here. Return true if you applied changes to override usual jump behavior, return false otherwise.
func _jump_override() -> bool:
	#if _get_special_flag("attacking"):
		#return true
	return false

## Sprite flip check function. Return true if you need the sprite to not flip under certain circumstances.
func _flip_check() -> bool:
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
