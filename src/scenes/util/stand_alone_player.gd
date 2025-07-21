extends AudioStreamPlayer


func set_sfx(sfx, random: bool):
	stream = sfx
	if random:
		pitch_scale = randf_range(0.8, 1.2)
	play()


func _on_finished():
	queue_free()
