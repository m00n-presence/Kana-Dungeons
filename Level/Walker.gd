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
	for x in room_size.x:
		for y in room_size.y:
			var new_step: Vector2 = top_left_corner + Vector2(x, y)
			if borders.has_point(new_step):
				steps_made.append(new_step)
	var room_for_addition: Rect2 = _transform_to_room_for_addition(new_room)
	if is_room(room_for_addition):
		rooms.append(room_for_addition)

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

# Проверяет, подходит ли прямоугольник под критерии комнаты
func is_room(rect: Rect2) -> bool:
	return rect.size.x > 1 && rect.size.y > 1

# Возвращает комнату, которую нужно добавить, с учетом уже имеющихся комнат
func _transform_to_room_for_addition(rect: Rect2) -> Rect2:
	if !is_room(rect):
		return Rect2()
	var in_bounds_rect: Rect2 = rect.clip(borders)
	var merge_with = [false, Rect2()]
	var remove_room = [false, Rect2()]
	var cut_room = [false, Rect2(), Rect2()] # флаг; от какой комнаты отрезать; часть, кот-ю отрезать 
	for room in rooms:
		if room.encloses(in_bounds_rect):
			return Rect2()
		elif in_bounds_rect.encloses(room):
			remove_room[0] = true
			remove_room[1] = room
			break
		elif in_bounds_rect.intersects(room, true):
			if rooms_in_same_row_column(in_bounds_rect, room):
				merge_with[0] = true
				merge_with[1] = room
				break
			else:
				var intersection: Rect2 = in_bounds_rect.clip(room)
				if rooms_in_same_row_column(intersection, in_bounds_rect):
					if in_bounds_rect.position == intersection.position || in_bounds_rect.end == intersection.end:
						return _cut_off_intersection(in_bounds_rect, intersection)
					else:
						return Rect2()
				elif rooms_in_same_row_column(intersection, room) \
					 && (room.position == intersection.position || room.end == intersection.end):
					cut_room[0] = true
					cut_room[1] = room
					cut_room[2] = intersection
					break
	if merge_with[0]:
		var merged_room: Rect2 = in_bounds_rect.merge(merge_with[1])
		rooms.erase(merge_with[1])
		return merged_room
	if cut_room[0]:
		var room_without_intersection: Rect2 = _cut_off_intersection(cut_room[1], cut_room[2])
		if is_room(room_without_intersection):
			rooms.append(room_without_intersection)
		rooms.erase(cut_room[1])
	if remove_room[0]:
		rooms.erase(remove_room[1])
	return in_bounds_rect

# Проверяет, что комнаты находятся в одной "колонне" или "ряду":
# Если одинаковы их Х-координаты и их ширины
# или если одинаковы их Y-координаты и их длины
func rooms_in_same_row_column(room1: Rect2, room2: Rect2) -> bool:
	if (room1.position.x == room2.position.x && room1.size.x == room2.size.x) \
	  || (room1.position.y == room2.position.y && room1.size.y == room2.size.y):
		return true
	return false

# Вовращает часть от room, оставшуюся от intersection
# Т.е. intersection и возвращаемое значение этого метода составляют room
func _cut_off_intersection(room: Rect2, intersection: Rect2) -> Rect2:
	var residue_position: Vector2 = Vector2()
	var width: int = room.size.x if room.size.x == intersection.size.x else room.size.x - intersection.size.x
	var length: int = room.size.y if room.size.y == intersection.size.y else room.size.y - intersection.size.y
	var residue_size: Vector2 = Vector2(width, length)
	if room.position == intersection.position:
		if room.size.x == intersection.size.x:
			residue_position = Vector2(room.position.x, intersection.end.y)
		else:
			residue_position = Vector2(intersection.end.x, room.position.y)
	else:
		residue_position = room.position
	return Rect2(residue_position, residue_size)
