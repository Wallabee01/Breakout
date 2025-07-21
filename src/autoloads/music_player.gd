extends AudioStreamPlayer

#const titleMusic = preload("res://assets/sounds/music/Electronic Fantasy.ogg")
const game_music = preload("res://assets/audio/music/BoxCat_Games_-_13_-_Rolling.ogg")
#const gameover_music = preload("res://assets/audio/music/Game Over II.ogg")


func _ready():
	volume_db = -5


func stop_player():
	stop()

func change_music(flag: String):
	match flag:
		"title":
			pass
			#stop()
			#stream = titleMusic
			#play()
		"game":
			stop()
			stream = game_music
			stream.loop = true
			play()
		"gameover":
			pass
			#stop()
			#stream = gameover_music
			#play()
