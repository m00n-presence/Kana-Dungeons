extends Node
class_name Enemies_Generator

# Коллекция путей до сцен врагов
var enemies_scene_paths

func _init():
	enemies_scene_paths = [
		"res://Enemies/EnemyTsuHiragana.tscn"
	]

func get_enemies(count: int):
	pass
