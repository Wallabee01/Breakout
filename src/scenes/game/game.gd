extends Node

@onready var ball: Ball = %Ball
@onready var paddle: CharacterBody2D = %Paddle
@onready var gameover_stream_player: AudioStreamPlayer = %GameoverStreamPlayer
@onready var death_stream_player: AudioStreamPlayer = %DeathStreamPlayer
@onready var bricks: Node2D = %Bricks
@onready var brick_manager: Node = $BrickManager
@onready var life_label: Label = %LifeLabel
@onready var score_label: Label = %ScoreLabel
@onready var start_label: Label = %StartLabel
@onready var game_over_label: Label = %GameOverLabel
@onready var highscore_label: Label = %HighscoreLabel
@onready var balls: Node2D = %Balls
@onready var shield = %Shield

var lives: int = 3
var score: int = 0
var new_game: bool = false


func _ready():
	MusicPlayer.change_music("game")
	game_over_label.visible = false
	GameEvents.brick_destroyed.connect(_on_brick_destroyed)
	_update_life()
	_update_score()
	_update_high_score()
	spawn_bricks()


func _unhandled_input(event):
	if event.is_action_pressed("start") && !GameEvents.is_game_started:
		ball.linear_velocity = ball.get_velocity()
		
		if ball.linear_velocity.y > 0:
			ball.linear_velocity = Vector2(ball.linear_velocity.x, -ball.linear_velocity.y)
		
		GameEvents.is_game_started = true
		start_label.visible = false
		game_over_label.visible = false
		
		if new_game:
			spawn_bricks()
			ball.reset_speed()
		
		get_tree().root.set_input_as_handled()


func _update_life(num: int = 0):
	lives += num
	life_label.text = "Lives: " + str(lives)


func _update_score(num: int = 0):
	score += num
	score_label.text = "Score: " + str(score)


func _update_high_score():
	highscore_label.text = "High Score: " + str(GameEvents.get_high_score())


func game_over():
	game_over_label.text = "GAME OVER\nScore: " + str(score)
	game_over_label.visible = true
	GameEvents.set_highscore(score)
	_update_high_score()
	score = 0
	_update_score()
	_update_life(3)
	new_game = true
	gameover_stream_player.play()
	paddle.is_ceiling_hit = false
	paddle.scale = Vector2(1.0, 1.0)


func spawn_bricks():
	call_deferred("remove_child", bricks)
	call_deferred("add_child", bricks)
	brick_manager.spawn_bricks()


func _reset_ball():
	var parent = ball.get_parent()
	
	parent.remove_child(ball)
	await get_tree().process_frame
	parent.add_child(ball)
	
	ball.global_position = ball.get_start_pos()
	ball.linear_velocity = Vector2.ZERO
	
	GameEvents.is_game_started = false
	new_game = false
	start_label.visible = true
	game_over_label.visible = false
	
	_reset_powerups()
	
	if lives == 0:
		game_over()


func _reset_powerups():
	PowerUps.reset_powerups.emit()
	
	for child in balls.get_children():
		child.queue_free()


func _on_death_area_2d_body_entered(body):
	if body.is_multi_ball:
		body.queue_free()
		return
	
	_update_life(-1)
	_reset_ball()
	if lives != 0:
		death_stream_player.play()


func _on_brick_destroyed():
	_update_score(1)

	if bricks.get_children().size() <= 1:
		spawn_bricks()


func _on_ceiling_area_2d_body_entered(body):
	body.bounce("Ceiling")
	if body == ball:
		if !paddle.is_ceiling_hit:
			paddle.is_ceiling_hit = true
			if paddle.is_large:
				paddle.scale = Vector2(1.32, 1.0)
			else:
				paddle.scale = Vector2(0.66, 1.0)
