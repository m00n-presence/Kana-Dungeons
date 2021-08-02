extends Node
class_name Enemies_Generator

# Коллекция путей до сцен врагов
var enemies_scene_paths
# Коллекция комнат, составленных Walker
var rooms
# Допустимые границы в пикселях
var borders: Rect2
# Коллекция комнат, в которые нельзя ставить врагов
var prohibited_rooms 

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
func get_spawn_points(enemies_count: int, excluding_rooms):
	prohibited_rooms = excluding_rooms
	rooms.shuffle()
	var spawn_points = []
	var total_spawns_count: int = 0
	while total_spawns_count <= enemies_count && !rooms.empty():
		var room: Rect2 = rooms.pop_back()
		var room_spawn_points = _get_random_spawns_in_room(room)
		append_range(spawn_points, room_spawn_points)
		#spawn_points.append_array(room_spawn_points)
		total_spawns_count = spawn_points.size()
	return spawn_points

func _get_random_spawns_in_room(room: Rect2):
	var possible_spawns = _get_all_possible_spawns_in_room(room)
	var max_count: int = ceil((possible_spawns.size() + 1) / 2)
	if max_count == 0:
		return []
	var spawns_count_in_room: int = randi() % max_count + 1
	possible_spawns.shuffle()
	possible_spawns.resize(spawns_count_in_room)
	return possible_spawns

func _get_all_possible_spawns_in_room(room: Rect2):
	var spawns = []
	var spawn_x_room_related = range(1, room.size.x)
	var spawn_y_room_related = range(1, room.size.y)
	for x in spawn_x_room_related:
		for y in spawn_y_room_related:
			var world_position_tile: Vector2 = room.position + Vector2(x, y)
			if !_any_prohibited_room_has_point(world_position_tile):
				spawns.append(world_position_tile)
	return spawns

func _any_prohibited_room_has_point(point_to_check: Vector2) -> bool:
	for room in prohibited_rooms:
		if room.has_point(point_to_check):
			return true
	return false

func append_range(source_array: Array, elements_to_add: Array):
	for e in elements_to_add:
		source_array.append(e)
