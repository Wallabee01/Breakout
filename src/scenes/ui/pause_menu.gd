extends CanvasLayer

var is_paused: bool = false


func _unhandled_input(event):
	if event.is_action_pressed("pause"):
		if !is_paused:
			get_tree().paused = true
			is_paused = true
			visible = true
		else:
			get_tree().paused = false
			is_paused = false
			visible = false
	
