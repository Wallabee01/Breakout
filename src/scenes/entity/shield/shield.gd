extends Area2D

@onready var collision_shape_2d = %CollisionShape2D
@onready var sprite_2d = $Sprite2D

var shield_strength: int = 0

func _ready():
	PowerUps.powerup.connect(_on_powerup)


func set_shield_color():
	match shield_strength:
		1:
			sprite_2d.modulate = Globals.COLOR_BLUE
		2:
			sprite_2d.modulate = Globals.COLOR_YELLOW
		3:
			sprite_2d.modulate = Globals.COLOR_GREEN
		4:
			sprite_2d.modulate = Globals.COLOR_ORANGE
		5:
			sprite_2d.modulate = Globals.COLOR_RED


func _on_powerup(powerup_type, _ball):
	if powerup_type == PowerUps.PowerUp.SHIELD:
		collision_shape_2d.set_deferred("disabled", false)
		sprite_2d.visible = true
		shield_strength += 1
		shield_strength = clampi(shield_strength, 0, 5)
		set_shield_color()


func _on_body_entered(body):
	body.bounce(name)
	shield_strength -= 1
	
	if shield_strength == 0:
		sprite_2d.visible = false
		collision_shape_2d.set_deferred("disabled", true)
	else:
		set_shield_color()
