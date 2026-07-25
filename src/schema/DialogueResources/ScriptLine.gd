extends Resource
class_name ScriptLine

# I hold a line of dialogue
# to move the camera I will call a global signal with a tag
# the object with the corresponding tag will set it's priorty to 2 or 0

enum camera_tags {
	NONE,A,B,C,D,E,F,G,H,I,J,K,L
}

@export_multiline() var dialog : String = ""
@export var name : String = "???"
@export var important : bool = false
@export var camera : camera_tags = camera_tags.NONE
