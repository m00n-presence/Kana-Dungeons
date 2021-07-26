extends Node
class_name Enemies_Generator

# Коллекция путей до сцен врагов
var enemies_scene_paths

# Словарь путей сцен врагов (ключ) и количества экземпляров этих врагов (значение)
var enemy_pathnames_to_count = {}

func _init():
	enemies_scene_paths = [
		"res://Enemies/EnemyTsuHiragana.tscn"
		# Добавлять пути новых сцен врагов по мере их создания
	]

func get_enemies(enemy_count: int):
	var paths_count: int = enemies_scene_paths.size()
	for num in enemy_count:
		var path_name = enemies_scene_paths[randi() % paths_count]
		if enemy_pathnames_to_count.has(path_name):
			enemy_pathnames_to_count[path_name] += 1
		else:
			enemy_pathnames_to_count[path_name] = 1
	return enemy_pathnames_to_count
