extends Node

signal powerup(powerup_type, ball)
signal reset_powerups

const POWERUP_CHANCE: float = 0.33333
const BALL_SCENE = preload("res://src/scenes/entity/ball/ball.tscn")

enum PowerUp {PADDLE_SIZE, PADDLE_MAGNET, PADDLE_SPLIT, BIG_BALL, FIRE_BALL, MULTI_BALL, SHIELD, BRICK_EXPLOSION}


func _ready():
	powerup.connect(_on_powerup)


func set_brick_powerup(brick: Brick):
		var powerup_type_roll: int = randi_range(0, PowerUp.size())
		match powerup_type_roll:
			0:
				brick.set_powerup(PowerUp.PADDLE_SIZE)
			1:
				brick.set_powerup(PowerUp.PADDLE_MAGNET)
			2:
				brick.set_powerup(PowerUp.PADDLE_SPLIT)
			3:
				brick.set_powerup(PowerUp.BIG_BALL)
			4:
				brick.set_powerup(PowerUp.FIRE_BALL)
			5:
				brick.set_powerup(PowerUp.MULTI_BALL)
			6:
				brick.set_powerup(PowerUp.SHIELD)
			7:
				brick.set_powerup(PowerUp.BRICK_EXPLOSION)


func emit_powerup_signal(powerup_type, ball):
	powerup.emit(powerup_type, ball)


func multi_ball(ball):
	var ball_instance = BALL_SCENE.instantiate()
	get_tree().get_first_node_in_group("game").find_child("Balls").call_deferred("add_child", ball_instance)
	await get_tree().process_frame 
	ball_instance.global_position = ball.global_position
	ball_instance.linear_velocity = Vector2(-ball.linear_velocity.x, ball.linear_velocity.y)
	ball_instance.is_multi_ball = true
	ball_instance.sprite_2d.texture = ball_instance.MULTI_BALL_TEXTURE
	ball_instance.gpu_particles_2d.process_material = ball_instance.gpu_particles_2d.process_material.duplicate(true)
	ball_instance.gpu_particles_2d.process_material.color_ramp.gradient = ball_instance.MULTI_GRADIENT
	
	ball_instance.multi_ball_timer.start()


func _on_powerup(powerup_type, ball):
	if powerup_type == PowerUp.MULTI_BALL:
		multi_ball(ball)
