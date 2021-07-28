extends Node
class_name Walker

const DIRECTIONS = [Vector2.LEFT, Vector2.UP, Vector2.RIGHT, Vector2.DOWN]

var current_pos: Vector2 = Vector2.ZERO
var current_dir: Vector2 = Vector2.RIGHT
var borders: Rect2 = Rect2()
var steps_made = []
var steps_since_turn: int = 0
var rooms = []
var special_rooms = []

func _init(starting_pos: Vector2, new_borders: Rect2):
	assert(new_borders.has_point(starting_pos))
	current_pos = starting_pos
	steps_made.append(current_pos)
	borders = new_borders

func walk_for(steps_amount: int):
	place_normal_room(current_pos)
	for step in steps_amount:
		if steps_since_turn >= 6: #randf() <= 0.30 or 
			change_direction()
			if (special_rooms.size() < 3 and randf() <= 0.4):
				place_special_room(current_pos)
		elif step():
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
	place_normal_room(current_pos)
	steps_since_turn = 0
	var directions = DIRECTIONS.duplicate()
	directions.erase(current_dir)
	directions.shuffle()
	current_dir = directions.pop_back() #pop_front
	while not borders.has_point(current_dir + current_pos):
		current_dir = directions.pop_back()

func place_normal_room(position: Vector2) -> void:
	var room_size: Vector2 = Vector2(randi() % 4 + 2, randi() % 4 + 1)
	var top_left_corner: Vector2 = (position - room_size / 2).ceil() #ceil
	var new_room: Rect2 = Rect2(top_left_corner, room_size)
	if is_room_inside_any_other(new_room):
		return
	for x in room_size.x:
		for y in room_size.y:
			var new_step: Vector2 = top_left_corner + Vector2(x, y)
			if borders.has_point(new_step):
				steps_made.append(new_step)
	if room_size.y > 1:
		rooms.append(get_merged_room_if_possible(new_room)) #room placement 

func place_special_room(_position: Vector2) -> void:
	var size = Vector2(3, 3)
	var top_left_corner: Vector2 = (current_pos - size / 2).floor()
	var room_rect: Rect2 = Rect2(top_left_corner, size)
	if special_rooms.has(room_rect):
		return
	#breakpoint
	special_rooms.append(room_rect)
	for x in size.x:
		for y in size.y:
			var new_step: Vector2 = top_left_corner + Vector2(x, y)
			if borders.has_point(new_step):
				steps_made.append(new_step)

func get_the_farthest_room(startroom_position: Vector2) -> Rect2:
	var farthest_room: Rect2 = rooms.pop_back()
	var longest_distance: int = startroom_position.distance_to(farthest_room.position)
	for room in rooms:
		var distance_to_room: int = startroom_position.distance_to(room.position)
		if  distance_to_room > longest_distance:
			farthest_room = room
			longest_distance = distance_to_room
	return farthest_room

# Проверяет, находится ли комната room_to_check полностью внутри любой другой комнаты из rooms
func is_room_inside_any_other(room_to_check: Rect2)-> bool:
	for room in rooms:
		if room.encloses(room_to_check):
			return true
	return false

# Если комнату room_to_check можно соединить с существующей комнатой, то возвращает 
# результат этого соединения. Если нет - то возвращает room_to_check.
# Комнаты можно соединить, если они пересекаются, их позиции имеют хотя бы 1 одинаковую координату, и
# если одинаковы x - то их ширины тоже должны быть равны, если равны y - то их высоты.
func get_merged_room_if_possible(room_to_check: Rect2) -> Rect2:
	var possible_merge_room: Rect2 = Rect2()
	for room in rooms:
		if room_to_check.position.x == room.position.x:
			if room_to_check.size.x == room.size.x && room_to_check.intersects(room, true):
				possible_merge_room = room
				break
		if room_to_check.position.y == room.position.y:
			if room_to_check.size.y == room.size.y && room_to_check.intersects(room, true):
				possible_merge_room = room
				break
	if !possible_merge_room.has_no_area():
		var merged_room: Rect2 = room_to_check.merge(possible_merge_room)
		rooms.erase(possible_merge_room)
		return merged_room
	return room_to_check


