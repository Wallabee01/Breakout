extends RigidBody2D
class_name Ball

const START_POS: Vector2 = Vector2(320, 256)
const START_VELOCITY: Vector2 = Vector2(-90, -90)
const BASE_SPEED: float = 100
const SPEED_INCREASE: float = 1.0
const NORMAL_GRADIENT = preload("res://resources/particles/gradients/normal_ball_gradient.tres")
const MULTI_GRADIENT = preload("res://resources/particles/gradients/multi_gradient.tres")
const FIRE_GRADIENT = preload("res://resources/particles/gradients/fire_ball_gradient.tres")
const FIRE_MULTI_GRADIENT = preload("res://resources/particles/gradients/fire_multi_gradient.tres")
const NORMAL_BALL_TEXTURE = preload("res://assets/game_objects/ball/MetalBall8x8.png")
const FIRE_BALL_TEXTURE = preload("res://assets/game_objects/ball/FireBall.png")
const MULTI_BALL_TEXTURE = preload("res://assets/game_objects/ball/MultiBall.png")
const FIRE_MULTI_BALL_TEXTURE = preload("res://assets/game_objects/ball/FireMultiBall.png")

var speed: float = BASE_SPEED
var velocity: Vector2
var normal_particle_gradient
var is_multi_ball: bool = false
var is_stuck_to_paddle: bool = false
var stick_offset: Vector2 = Vector2.ZERO
var stuck_velocity: Vector2 = Vector2.ZERO
var is_fire_ball: bool = false

@onready var gpu_particles_2d = %GPUParticles2D
@onready var collision_shape_2d = %CollisionShape2D
@onready var big_ball_timer = %BigBallTimer
@onready var fire_ball_timer = %FireBallTimer
@onready var multi_ball_timer = %MultiBallTimer
@onready var sprite_2d = %Sprite2D
@onready var bounce_stream_player = %BounceStreamPlayer
@onready var fire_stream_player = %FireStreamPlayer


func _ready():
	velocity = START_VELOCITY
	PowerUps.powerup.connect(_on_powerup)
	PowerUps.reset_powerups.connect(_on_reset_powerups)
	big_ball_timer.timeout.connect(_on_big_ball_timer_timeout)
	fire_ball_timer.timeout.connect(_on_fire_ball_timer_timeout)
	multi_ball_timer.timeout.connect(_on_multi_ball_timer_timeout)


func _physics_process(_delta):
	if is_stuck_to_paddle:
		global_position = GameEvents.get_paddle_global_position() + stick_offset
		if Input.is_action_just_pressed("start") && GameEvents.is_game_started && is_stuck_to_paddle:
			release_from_paddle()


func stick_to_paddle():
	stuck_velocity = linear_velocity
	stick_offset = global_position - GameEvents.get_paddle_global_position()
	is_stuck_to_paddle = true
	linear_velocity = Vector2.ZERO


func release_from_paddle():
	is_stuck_to_paddle = false
	linear_velocity = stuck_velocity


func get_start_pos() -> Vector2:
	return START_POS


func get_start_velocity() -> Vector2:
	return START_VELOCITY


func get_velocity() -> Vector2:
	return velocity


func reset_speed():
	velocity = START_VELOCITY
	linear_velocity = START_VELOCITY
	speed = BASE_SPEED


func bounce(area_name: String):
	if is_fire_ball && area_name == "Brick":
		fire_stream_player.play()
		return
	
	speed += SPEED_INCREASE
	var velocity_normalized = linear_velocity.normalized()
	linear_velocity = Vector2(velocity_normalized.x * speed, -velocity_normalized.y * speed)
	velocity = linear_velocity
	
	bounce_stream_player.pitch_scale = randf_range(0.8, 1.2)
	bounce_stream_player.play()


func deflect_off_paddle(paddle: Node2D):
	var offset = (global_position.x - paddle.global_position.x) / (paddle.get_node("CollisionShape2D").shape.extents.x)
	offset = clamp(offset * 2, -2.0, 2.0) 
	
	var direction = Vector2(offset, -1).normalized()
	linear_velocity = direction  * speed
	
	bounce_stream_player.pitch_scale = randf_range(0.8, 1.2)
	bounce_stream_player.play()


func _on_powerup(powerup_type, ball):
	if ball != self: return
	
	if powerup_type == PowerUps.PowerUp.BIG_BALL:
		big_ball_timer.start()
		var big_ball_scale = Vector2(2.0, 2.0)
		gpu_particles_2d.process_material = gpu_particles_2d.process_material.duplicate()
		gpu_particles_2d.process_material.scale = Vector2(0.25, 0.25)
		sprite_2d.scale = big_ball_scale
		collision_shape_2d.scale = big_ball_scale
	elif powerup_type == PowerUps.PowerUp.FIRE_BALL:
		fire_ball_timer.start()
		is_fire_ball = true
		if is_multi_ball:
			sprite_2d.texture = FIRE_MULTI_BALL_TEXTURE
			gpu_particles_2d.process_material.color_ramp.gradient = FIRE_MULTI_GRADIENT
		else:
			sprite_2d.texture = FIRE_BALL_TEXTURE
			gpu_particles_2d.process_material.color_ramp.gradient = FIRE_GRADIENT


func _on_big_ball_timer_timeout():
	var normal_ball_scale = Vector2(1.0, 1.0)
	gpu_particles_2d.process_material.scale = Vector2(0.125, 0.125)
	sprite_2d.scale = normal_ball_scale
	collision_shape_2d.scale = normal_ball_scale


func _on_fire_ball_timer_timeout():
	is_fire_ball = false
	if is_multi_ball:
		sprite_2d.texture = MULTI_BALL_TEXTURE
		gpu_particles_2d.process_material.color_ramp.gradient = MULTI_GRADIENT
	else:
		sprite_2d.texture = NORMAL_BALL_TEXTURE
		gpu_particles_2d.process_material.color_ramp.gradient = NORMAL_GRADIENT


func _on_multi_ball_timer_timeout():
	call_deferred("queue_free")


func _on_reset_powerups():
	_on_big_ball_timer_timeout()
	_on_fire_ball_timer_timeout()
