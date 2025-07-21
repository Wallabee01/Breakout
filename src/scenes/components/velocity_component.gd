extends Node
class_name VelocityComponent

@export var max_speed: int = 40
@export var acceleration: float = 5.0

var velocity = Vector2.ZERO


func move(character_body: CharacterBody2D, direction: Vector2):
	_accelerate_in_direction(direction)
	
	character_body.velocity = velocity
	character_body.move_and_slide()
	#move_and_slide() returns the remaining velocity, but is internal to CharacterBody2D
	#so if we want to capture the remaining velocity, we need to assign our VelocityComponent's 
	#velocity to it, will only be different if the CharacterBody2D collides with something
	velocity = character_body.velocity


func _accelerate_in_direction(direction: Vector2):
	var final_velocity = direction * max_speed
	velocity = velocity.lerp(final_velocity, 1 - exp(-acceleration * get_process_delta_time()))
