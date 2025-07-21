extends Node

const BRICK_SCENE = preload("res://src/scenes/entity/brick/brick.tscn")
const NUM_BRICKS_IN_ROW = 16
const NUM_BRICK_COL = 8
const BRICK_SIZE = Vector2(32, 8)
const BRICK_CENTER = Vector2(BRICK_SIZE.x / 2, BRICK_SIZE.y / 2)
const VIEWPORT_SIZE = Vector2(640, 360)

@export var brick_parent: Node2D


func spawn_bricks():
	await get_tree().process_frame
	
	var initial_position = Vector2(4 + BRICK_CENTER.x, (VIEWPORT_SIZE.y / 4) + BRICK_CENTER.y + (BRICK_SIZE.y * 4))
	
	for i in NUM_BRICK_COL:
		for j in NUM_BRICKS_IN_ROW:
			var brick_instance: Brick = BRICK_SCENE.instantiate()
			brick_parent.add_child(brick_instance)
			
			var brick_position = Vector2(initial_position.x + (j * (BRICK_SIZE.x + 8)), initial_position.y + (i * (-BRICK_SIZE.y - 4)))
			brick_instance.global_position = brick_position
			match i:
				0, 1:
					brick_instance.set_color(Globals.COLOR_YELLOW)
				2, 3:
					brick_instance.set_color(Globals.COLOR_GREEN)
				4, 5:
					brick_instance.set_color(Globals.COLOR_ORANGE)
				6, 7:
					brick_instance.set_color(Globals.COLOR_RED)
			
			var powerup_chance_roll: float = randf()
			if powerup_chance_roll <= PowerUps.POWERUP_CHANCE:
				PowerUps.set_brick_powerup(brick_instance)
