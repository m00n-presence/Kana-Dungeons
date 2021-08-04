extends Node
class_name Enemies_Generator

# Коллекция путей до сцен врагов
var enemies_scene_paths
# Коллекция комнат, составленных Walker
var rooms
# Допустимые границы в пикселях
var borders: Rect2
# Коллекция точек, на которые нельзя ставить врагов
var banned_points

# Словарь путей сцен врагов (ключ) и количества экземпляров этих врагов (значение)
var enemy_pathnames_to_count = {}

func _init(walker_rooms):
	enemies_scene_paths = [
		"res://Enemies/EnemyTsuHiragana.tscn"
		# Добавлять пути новых сцен врагов по мере их создания
	]
	rooms = walker_rooms.duplicate()

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
	var max_spawns_around: int = 2
	
	rooms.shuffle()
	var spawn_points = []
	var total_spawns_count: int = 0
	while total_spawns_count <= enemies_count && !rooms.empty():
		var room: Rect2 = rooms.pop_back()
		var room_spawn_points: Array = _get_random_spawns_in_room(room)
		for possible_spawn in room_spawn_points:
			if possible_spawn == null:
				 break
			if !_is_radius_around_crowded(possible_spawn, radius, max_spawns_around, spawn_points):
				spawn_points.append(shuffle_point_in_range(possible_spawn * 192, 100))
		total_spawns_count = spawn_points.size()
	return spawn_points

# Вовращает случайные точки спавна в комнате
func _get_random_spawns_in_room(room: Rect2):
	var possible_spawns = _get_all_possible_spawns_in_room(room)
	var max_count: int = ceil(0.5 * (possible_spawns.size() + 1) / 2)
	if max_count == 0:
		return []
	var spawns_count_in_room: int = randi() % max_count + 1
	possible_spawns.shuffle()
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

# Проверяет, что в радиусе radius от точки point не больше max_allowed_spawns 
# точек спавна из spawn_points
func _is_radius_around_crowded(point: Vector2, radius: int, max_allowed_spawns: int, spawn_points: Array) -> bool:
	var spawns_around: int = 0
	for spawn in spawn_points:
		if point.distance_to(spawn) < radius:
			spawns_around += 1
		if spawns_around >= max_allowed_spawns:
			return true
	return false

# Возвращает все точки спавна в запрещенных комнатах
func _get_banned_points(banned_rooms: Array) -> Array:
	var banned_points: Array = []
	for room in banned_rooms:
		var in_room_points: Array = _get_all_possible_spawns_in_room(room, false)
		append_range(banned_points, in_room_points)
	return banned_points

# Возвращает случайную точки в max_range радиусе от данной
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