extends CanvasLayer

@export var start_label: Label

var is_paused: bool = false
var is_start_label_visible: bool = false


func _unhandled_input(event):
	if event.is_action_pressed("pause"):
		if !is_paused:
			get_tree().paused = true
			is_paused = true
			visible = true
			is_start_label_visible = start_label.visible
			start_label.visible = false
		else:
			get_tree().paused = false
			is_paused = false
			visible = false
			start_label.visible = is_start_label_visible
	


func _on_button_pressed():
	get_tree().quit()
