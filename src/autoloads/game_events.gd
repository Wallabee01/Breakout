extends Node

signal brick_destroyed

const SAVE_FILE_PATH = "user://game.save"

var high_score: int = 0
var is_game_started: bool = false
var is_magnet_ball_on_paddle: bool = false
var paddle_global_position: Vector2 = Vector2.ZERO

func _ready():
	load_save_file()


func get_paddle_global_position() -> Vector2:
	return paddle_global_position


func get_high_score() -> int:
	return high_score


func load_save_file():
	if !FileAccess.file_exists(SAVE_FILE_PATH): return
	
	var file = FileAccess.open(SAVE_FILE_PATH, FileAccess.READ)
	high_score = file.get_var()


func save():
	var file = FileAccess.open(SAVE_FILE_PATH, FileAccess.WRITE)
	file.store_var(high_score)


func set_highscore(score: int):
	if score > high_score:
		high_score = score
		save()
