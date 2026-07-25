extends Resource
class_name ScriptPack
# I hold multiple script lines! and play a script when requested

@export var scp : Array[ScriptLine] = []


func play_scp():
	for i in scp:
		Dungeon.play_dialog.emit(
			i.dialog,i.name,i.important
		)
		if i.camera != ScriptLine.camera_tags.NONE:
			Dungeon.move_camera.emit(i.camera,true)
		await Dungeon.dialog_waiting
		await Dungeon.multiInputDelay(["move_up","move_down","move_left","move_right","jump","attack"])
		await Dungeon.multiDelayRelease(["move_up","move_down","move_left","move_right","jump","attack"])
	Dungeon.reset_camera.emit()
	Dungeon.end_dialog.emit()
