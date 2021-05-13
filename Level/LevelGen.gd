extends Node2D

const QUESTION_NUMBER: int = 3
const ANSWERS_COUNT: int = 3

signal level_generated(starting_pos)

var borders: Rect2 = Rect2(1, 1, 25, 20)
var player_starting_point = Vector2(13, 10) * 192

onready var wallsTileMap = $WallTileMap
onready var floorTileMap = $FloorTileMap


func _ready():
	randomize()
	generate_level()
	generate_questions()
	emit_signal("level_generated", player_starting_point)
	

func generate_level():
	var walker = Walker.new(Vector2(13, 10), borders)
	var map = walker.walk_for(300)
	
	for location in map:
		wallsTileMap.set_cellv(location, -1)
		floorTileMap.set_cellv(location, 0)
	wallsTileMap.update_bitmask_region(borders.position, borders.end)
	floorTileMap.update_bitmask_region(borders.position, borders.end)
	
	place_question_pedestals(walker.special_rooms)
	place_enemies(walker.rooms)
	place_enhancing_item(walker)
	walker.queue_free()
	#emit_signal("level_generated", player_starting_point)

func place_enemies(rooms_rects):
	#var testEnemyScene = preload("res://testEnemy.tscn")
	var tsuEnemy = preload("res://Enemies/EnemyTsuHiragana.tscn")
	var rooms_since_last_enemy: int = 0
	var enemy_count: int = 10
	for room in rooms_rects:
		if room.size.x < 2 || room.size.y < 2 || rooms_since_last_enemy <= 2: 
			rooms_since_last_enemy += 1
			continue
		var tile_position: Vector2 = room.position + room.size / 2
		if tile_position == Vector2(13, 10):
			continue
		var enemy = tsuEnemy.instance()
		enemy.position = tile_position * 192
		wallsTileMap.add_child(enemy)
		#self.add_child(enemy)
		rooms_since_last_enemy = 0
		enemy_count -= 1
		if enemy_count <= 0:
			break

func place_question_pedestals(special_rooms) -> void:
	var pedestal = load("res://QuestionPedestal/Pedestal.tscn")
	for special_room in special_rooms:
		var tile_pos: Vector2 = special_room.position + special_room.size / 2
		var instanced_pedestal = pedestal.instance()
		instanced_pedestal.position = tile_pos * 192
		wallsTileMap.add_child(instanced_pedestal)
		#self.add_child(instanced_pedestal)

func generate_questions():
	var generator = Question_Generator.new()
	var question_info = {}
	while question_info.size() < QUESTION_NUMBER:
		var kana_index: int = generator.get_random_kana_index()
		question_info[kana_index] = generator.get_random_answers_for_kana_index(kana_index, ANSWERS_COUNT)
	generator.queue_free()
	var control_question: PackedScene = load("res://QuestionPedestal/ControlQuestion.tscn")
	var pedestals = get_tree().get_nodes_in_group("pedestals")
	for pedestal in pedestals:
		var kana: int = question_info.keys()[0]
		pedestal.bind_question(control_question.instance(), kana, question_info[kana])
		question_info.erase(kana)

func place_enhancing_item(walker: Walker):
	var item = load("res://Items/item_I_hiragana.tscn")
	var item_tile_position: Vector2 = get_room_center(walker.get_the_farthest_room(player_starting_point / 192))
	print(item_tile_position)
	var item_instance = item.instance()
	item_instance.position = item_tile_position * 192 #+ Vector2(96, 96)
	print(item_instance.position)
	#player_starting_point = item_instance.position 
	wallsTileMap.add_child(item_instance)

func get_room_center(of_room: Rect2) -> Vector2:
	return of_room.position + (of_room.size / 2)
