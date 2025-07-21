extends Area2D
class_name Brick

#TODO: Make icons for each powerup and set on top of powerup bricks
const POWERUP_FIRE_BALL_TEXTURE = preload("res://assets/game_objects/ball/FireBall.png")
const POWERUP_BALL_TEXTURE = preload("res://assets/game_objects/ball/MetalBall8x8.png")
const EXPLOSION_SCENE = preload("res://src/scenes/standalones/explosion.tscn")

var is_powerup: bool = false
var powerup
var powerup_type_local
var ball

@onready var animation_player = $AnimationPlayer
@onready var powerup_sprite_2d = $PowerupSprite2D
@onready var sprite_2d = $Sprite2D
@onready var collision_shape_2d = %CollisionShape2D


func set_color(color: Color):
	sprite_2d.modulate = color


func set_powerup(powerup_type):
	is_powerup = true
	animation_player.play("pulse")
	powerup = powerup_type
	powerup_type_local = powerup_type
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
	
	if powerup_type_local == PowerUps.PowerUp.BRICK_EXPLOSION:
		var explosion_instance = EXPLOSION_SCENE.instantiate()
		get_parent().add_child(explosion_instance)
		explosion_instance.global_position = global_position
		ball = body
		collision_shape_2d.set_deferred("disabled", false)
	else:
		call_deferred("queue_free")


func _on_explosion_area_2d_area_entered(area):
	if area is Brick:
		if is_powerup:
			print(area.powerup)
			PowerUps.emit_powerup_signal(area.powerup, ball)
		area.call_deferred("queue_free")
		call_deferred("queue_free")
