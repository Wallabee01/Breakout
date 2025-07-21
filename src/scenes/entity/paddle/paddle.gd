extends CharacterBody2D

const NORMAL_COLOR: Color = Color(0.0, 1.0, 1.0, 1.0)
const MAGNET_COLOR: Color = Color(117.0/255.0, 117.0/255.0, 117.0/255.0, 1.0)
const BALL_SCENE: PackedScene = preload("res://src/scenes/entity/ball/ball.tscn")
const SPLIT_GAP: float = 64.0

var is_magnet: bool = false
var is_large: bool = false
var is_split: bool = false
var is_ceiling_hit: bool = false

@onready var split_sprite_2d: Sprite2D = %SplitSprite2D
@onready var normal_sprite_2d: Sprite2D = %NormalSprite2D
@onready var velocity_component: VelocityComponent = $VelocityComponent
@onready var size_timer: Timer = %SizeTimer
@onready var magnet_timer: Timer = %MagnetTimer
@onready var split_timer: Timer = %SplitTimer
@onready var paddle_collision_shape_2d: CollisionShape2D = %PaddleCollisionShape2D
@onready var split_area_collision_shape_2d: CollisionShape2D = %SplitAreaCollisionShape2D
@onready var split_collision_shape_2d: CollisionShape2D = %CollisionShape2D
@onready var split_paddle = %SplitPaddle
@onready var normal_paddle = %NormalPaddle


func _ready():
	PowerUps.powerup.connect(_on_powerup)
	PowerUps.reset_powerups.connect(_on_reset_powerups)
	size_timer.timeout.connect(_on_size_timer_timeout)
	magnet_timer.timeout.connect(_on_magnet_timer_timeout)
	split_timer.timeout.connect(_on_split_timer_timeout)


func _process(_delta):
	var movement_vector = _get_movement_vector()
	var direction = movement_vector.normalized()
	velocity_component.move(self, direction)


func _physics_process(_delta):
	GameEvents.paddle_global_position = global_position


func _get_movement_vector() -> Vector2:
	var x_movement = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	
	return Vector2(x_movement, 0)


func _set_color(color: Color):
	normal_sprite_2d.modulate = color
	split_sprite_2d.modulate = color


func _init_split():
	if is_split == true: return
	is_split = true
	normal_paddle.position.x -= SPLIT_GAP
	split_paddle.position.x += SPLIT_GAP
	
	if !is_large:
		if global_position.x < SPLIT_GAP / 2 + split_collision_shape_2d.shape.extents.x:
			global_position.x = SPLIT_GAP / 2 + split_collision_shape_2d.shape.extents.x
		if global_position.x > 640 - SPLIT_GAP / 2 - split_collision_shape_2d.shape.extents.x:
			global_position.x = 640 - SPLIT_GAP / 2 - split_collision_shape_2d.shape.extents.x
	else:
		if global_position.x < SPLIT_GAP + split_collision_shape_2d.shape.size.x * 2:
			global_position.x = SPLIT_GAP + split_collision_shape_2d.shape.size.x * 2
		if global_position.x > 640 - SPLIT_GAP - split_collision_shape_2d.shape.size.x * 2:
			global_position.x = 640 - SPLIT_GAP - split_collision_shape_2d.shape.size.x * 2

	split_sprite_2d.visible = true
	paddle_collision_shape_2d.shape.size.x = SPLIT_GAP * 2 + (split_collision_shape_2d.shape.size.x)
	split_area_collision_shape_2d.set_deferred("disabled", false)
	split_collision_shape_2d.set_deferred("disabled", false)


func _on_normal_area_2d_body_entered(body):
	body.deflect_off_paddle(normal_paddle)
	
	if is_magnet:
		GameEvents.paddle_global_position = global_position
		body.stick_to_paddle()


func _on_split_area_2d_body_entered(body):
	body.deflect_off_paddle(split_paddle)
	
	if is_magnet:
		GameEvents.paddle_global_position = global_position
		body.stick_to_paddle()


func _on_powerup(powerup_type, _ball_name):
	if powerup_type == PowerUps.PowerUp.PADDLE_SIZE:
		if !is_large:
			if is_ceiling_hit:
				scale = Vector2(1.32, 1.0)
			else:
				scale = Vector2(2.0, 1.0)
			is_large = true
			
			if is_split:
				if global_position.x < SPLIT_GAP + split_collision_shape_2d.shape.size.x * 2:
					global_position.x = SPLIT_GAP + split_collision_shape_2d.shape.size.x * 2
				if global_position.x > 640 - SPLIT_GAP - split_collision_shape_2d.shape.size.x * 2:
					global_position.x = 640 - SPLIT_GAP - split_collision_shape_2d.shape.size.x * 2
		
		size_timer.start()
	elif powerup_type == PowerUps.PowerUp.PADDLE_MAGNET:
		is_magnet = true
		magnet_timer.start()
		_set_color(MAGNET_COLOR)
	elif powerup_type == PowerUps.PowerUp.PADDLE_SPLIT:
		if !is_split:
			_init_split()
		split_timer.start()


func _on_size_timer_timeout():
	is_large = false
	if is_ceiling_hit:
		scale = Vector2(0.66, 1.0)
	else:
		scale = Vector2(1.0, 1.0)


func _on_magnet_timer_timeout():
	is_magnet = false
	_set_color(NORMAL_COLOR)


func _on_split_timer_timeout():
	is_split = false
	paddle_collision_shape_2d.shape.extents.x = split_collision_shape_2d.shape.extents.x
	normal_paddle.position.x = 0
	split_paddle.position.x = 0
	split_sprite_2d.visible = false
	split_area_collision_shape_2d.set_deferred("disabled", true)
	split_collision_shape_2d.set_deferred("disabled", true)


func _on_reset_powerups():
	if is_large:
		_on_size_timer_timeout()
	if is_split:
		_on_split_timer_timeout()
	if is_magnet:
		_on_magnet_timer_timeout()
	
	_set_color(NORMAL_COLOR)
