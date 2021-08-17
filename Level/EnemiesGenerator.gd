extends Node
class_name Enemies_Generator

# Коллекция путей до сцен врагов
var enemies_scene_paths
# Коллекция комнат, составленных Walker
var rooms: Array
# Коллекция точек, на которые нельзя ставить врагов
var banned_points
# Словарь: комната (координаты в тайлах) - массив точек спавна внутри этой комнаты
var rooms_to_spawn_count: Dictionary

# Словарь путей сцен врагов (ключ) и количества экземпляров этих врагов (значение)
var enemy_pathnames_to_count = {}

func _init(walker_rooms):
	enemies_scene_paths = [
		"res://Enemies/EnemyTsuHiragana.tscn"
		# Добавлять пути новых сцен врагов по мере их создания
	]
	rooms = walker_rooms.duplicate()
	_sort_rooms_by_size()

# Возвращает словарь: ключ - путь до файла сцены врага, 
# значение - сколько нужно распаковать экземпляров этого врага
func get_enemies(enemy_count: int):
	var paths_count: int = enemies_scene_paths.size()
	for num in enemy_count:
		var path_name = enemies_scene_paths[randi() % paths_count]
		if enemy_pathnames_to_count.has(path_name):
			enemy_pathnames_to_count[path_name] += 1
		else:
			enemy_pathnames_to_count[path_name] = 1
	return enemy_pathnames_to_count

# Возвращает список возможных позиций врагов 
func get_spawn_points(enemies_count: int, excluding_rooms: Array):
	banned_points = _get_banned_points(excluding_rooms)
	# В radius тайлах вокруг данной точки спавна  может быть до max_spawns_around других точек спавна
	var radius: int = 3
	var max_spawns_around: int = 3
	
	var spawn_points = []
	var total_spawns_count: int = 0
	while total_spawns_count <= enemies_count && !rooms.empty():
		var room: Rect2 = rooms.pop_back()
		var max_spawns: int = _get_max_spawns_relative_to_rooms_around(room, room.size.x * room.size.y, max_spawns_around)
		var room_spawn_points: Array = _get_random_spawns_in_room(room, max_spawns)
		for possible_spawn in room_spawn_points:
			spawn_points.append(shuffle_point_in_range(possible_spawn * 192, 130))
		rooms_to_spawn_count[room] = room_spawn_points.size()
		total_spawns_count = spawn_points.size()
	return spawn_points

# Вовращает случайные точки спавна в комнате
func _get_random_spawns_in_room(room: Rect2, max_spawns: int):
	var possible_spawns = _get_all_possible_spawns_in_room(room)
	if possible_spawns.empty():
		return []
	var max_count: int = ceil((possible_spawns.size() + 1) / 2)
	var spawns_count_in_room: int = min(randi() % max_count + 1, max_spawns)
	possible_spawns.shuffle()
	if possible_spawns.size() > spawns_count_in_room:
		possible_spawns.resize(spawns_count_in_room)
	return possible_spawns

# Возвращает все точки спавна в комнате. Если check_for_banned_points = true, то ещё проверяет,
# чтобы точка не была в запрещенных
# Точка спавна - левый верхний угол тайла, не принадлежащий стене
func _get_all_possible_spawns_in_room(room: Rect2, check_for_banned_points: bool = true):
	var spawns = []
	var spawn_x_room_related = range(1, room.size.x)
	var spawn_y_room_related = range(1, room.size.y)
	for x in spawn_x_room_related:
		for y in spawn_y_room_related:
			var world_position_tile: Vector2 = room.position + Vector2(x, y)
			if !check_for_banned_points || !banned_points.has(world_position_tile):
				spawns.append(world_position_tile)
	return spawns

# Возвращает максимально возможное количество точек спавна в данной комнате, 
# с учетом заполненности близлежащих комнат. 
# spawns_in_room - уже сгенерированное количество спавнов в данной комнате
func _get_max_spawns_relative_to_rooms_around(room_to_check: Rect2, spawns_in_room: int, max_spawns_per_room: int) -> int:
	var max_tile_radius: int = 2
	var crowded_rooms_around: int = 0
	for room in rooms_to_spawn_count:
		if is_room_close_to_other(room_to_check, room, max_tile_radius):
			if rooms_to_spawn_count[room] >= max_spawns_per_room:
				crowded_rooms_around += 1
				if crowded_rooms_around >= 4:
					break
	var room_area: int = room_to_check.size.x * room_to_check.size.y
	if crowded_rooms_around >= 3:
		if room_area <= 9:
			return 1
		elif room_area <= 18:
			return 2
		return 3
	elif crowded_rooms_around > 1:
		if room_area < 9:
			return 3
		elif room_area < 18:
			return 4
		return 5
	return spawns_in_room

# Сортирует комнаты по возрастанию их площади пузырьковой сортировкой
func _sort_rooms_by_size():
	var i: int = rooms.size() - 1
	while i > 0:
		var j: int = 1
		while j <= i:
			if get_room_area(rooms[j - 1]) > get_room_area(rooms[j]):
				var temp: Rect2 = rooms[j - 1]
				rooms[j - 1] = rooms[j]
				rooms[j] = temp
			j += 1
		i -= 1

# Возвращает все точки спавна в запрещенных комнатах
func _get_banned_points(banned_rooms: Array) -> Array:
	var ban_points: Array = []
	for room in banned_rooms:
		var in_room_points: Array = _get_all_possible_spawns_in_room(room, false)
		append_range(ban_points, in_room_points)
	return ban_points

# Возвращает случайную точку в max_range радиусе от данной
func shuffle_point_in_range(point: Vector2, max_range: int) -> Vector2:
	var radius: int = randf() * max_range
	var angle: float = 2 * PI * randf()
	var new_x: int = point.x + radius * cos(angle)
	var new_y: int = point.y + radius * sin(angle)
	return Vector2(new_x, new_y)

# Добавляет в source_array все элементы из elements_to_add
func append_range(source_array: Array, elements_to_add: Array):
	for e in elements_to_add:
		source_array.append(e)

# Проверяет, что хотя бы 1 стена каждой комнаты находится 
# в пределах max_tile_radius от стены другой комнаты
func is_room_close_to_other(room1: Rect2, room2: Rect2, max_tile_radius: int)-> bool:
	if room1.intersects(room2):
		return true
	var tl1_to_br2: Vector2 = (room1.position - room2.end).abs()
	var br1_to_tl2: Vector2 = (room1.end - room2.position).abs()
	return tl1_to_br2.x <= max_tile_radius || tl1_to_br2.y <= max_tile_radius \
		   || br1_to_tl2.x <= max_tile_radius || br1_to_tl2.y <= max_tile_radius

# Возвращает площадь комнаты
func get_room_area(room: Rect2) -> float:
	return room.size.x * room.size.y
