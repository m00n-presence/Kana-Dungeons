extends Node
class_name Walker

const DIRECTIONS = [Vector2.LEFT, Vector2.UP, Vector2.RIGHT, Vector2.DOWN]

var current_pos: Vector2 = Vector2.ZERO
var current_dir: Vector2 = Vector2.RIGHT
var borders: Rect2 = Rect2()
var steps_made = []
var steps_since_turn: int = 0
var rooms = []

func _init(starting_pos: Vector2, new_borders: Rect2):
	assert(new_borders.has_point(starting_pos))
	current_pos = starting_pos
	steps_made.append(current_pos)
	borders = new_borders

func walk_for(steps_amount: int):
	place_room(current_pos)
	for step in steps_amount:
		if steps_since_turn >= 6: #randf() <= 0.30 or 
			change_direction()
		if step():
			steps_made.append(current_pos)
		else:
			change_direction()
	return steps_made

func step() -> bool:
	var target_pos: Vector2 = current_pos + current_dir
	if borders.has_point(target_pos):
		steps_since_turn += 1
		current_pos = target_pos
		return true
	return false

func change_direction() -> void:
	place_room(current_pos)
	steps_since_turn = 0
	var directions = DIRECTIONS.duplicate()
	directions.erase(current_dir)
	directions.shuffle()
	current_dir = directions.pop_back() #pop_front
	while not borders.has_point(current_dir + current_pos):
		current_dir = directions.pop_back()

func place_room(position: Vector2) -> void:
	var room_size: Vector2 = Vector2(randi() % 4 + 2, randi() % 4 + 1)
	var top_left_corner: Vector2 = (position - room_size / 2).ceil() #ceil
	rooms.append(Rect2(top_left_corner, room_size)) #room placement 
	for x in room_size.x:
		for y in room_size.y:
			var new_step: Vector2 = top_left_corner + Vector2(x, y)
			if borders.has_point(new_step):
				steps_made.append(new_step)




