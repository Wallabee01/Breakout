extends Area2D
class_name Brick

#TODO: Make icons for each powerup and set on top of powerup bricks
const POWERUP_FIRE_BALL_TEXTURE = preload("res://assets/game_objects/ball/FireBall.png")
const POWERUP_BALL_TEXTURE = preload("res://assets/game_objects/ball/MetalBall8x8.png")

var is_powerup: bool = false
var powerup

@onready var animation_player = $AnimationPlayer
@onready var powerup_sprite_2d = $PowerupSprite2D
@onready var sprite_2d = $Sprite2D


func set_color(color: Color):
	sprite_2d.modulate = color


func set_powerup(powerup_type):
	is_powerup = true
	animation_player.play("pulse")
	powerup = powerup_type
	#TODO: Powerup icons
	#if powerup_type == PowerUps.PowerUp.BIG_BALL:
		#powerup_sprite_2d.texture = POWERUP_BALL_TEXTURE
	#elif powerup_type == PowerUps.PowerUp.FIRE_BALL:
		#powerup_sprite_2d.texture = POWERUP_FIRE_BALL_TEXTURE


func _on_body_entered(body):
	if is_powerup:
		PowerUps.emit_powerup_signal(powerup, body)
	
	body.bounce("Brick")
	GameEvents.brick_destroyed.emit()
	call_deferred("queue_free")
