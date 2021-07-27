extends Node2D

const QUESTION_NUMBER: int = 3
const ANSWERS_COUNT: int = 3

signal level_generated(starting_pos)

var borders: Rect2 = Rect2(1, 1, 25, 20)
var player_starting_point = Vector2(13, 10) * 192
var exit_placed: bool = false

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
	var enemy_count: int = 10
	var rooms_count: int = rooms_rects.size()
	var hostiles_generator = Enemies_Generator.new()
	var enemy_scenes_to_instance_count = hostiles_generator.get_enemies(enemy_count)
	for enemy_scene_path in enemy_scenes_to_instance_count:
		var enemy_scene: PackedScene = load(enemy_scene_path)
		for num in enemy_scenes_to_instance_count[enemy_scene_path]:
			var room = rooms_rects[randi() % rooms_count]
			var room_center_tile: Vector2 = room.position + room.size / 2
			var enemy = enemy_scene.instance()
			enemy.position = room_center_tile * 192
			wallsTileMap.add_child(enemy)
	hostiles_generator.queue_free()

func place_question_pedestals(special_rooms) -> void:
	var pedestal = load("res://QuestionPedestal/Pedestal.tscn")
	for special_room in special_rooms:
		var tile_pos: Vector2 = special_room.position + special_room.size / 2
		var instanced_pedestal = pedestal.instance()
		instanced_pedestal.position = tile_pos * 192
		print("Pedestal coordinate" + str(instanced_pedestal.position))
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
		pedestal.connect("question_answered_right", self, "on_right_answer")

func place_enhancing_item(walker: Walker):
	var item = load("res://Items/item_I_hiragana.tscn")
	var item_tile_position: Vector2 = get_room_center(walker.get_the_farthest_room(player_starting_point / 192))
	print("Item tile position" + str(item_tile_position))
	var item_instance = item.instance()
	item_instance.position = item_tile_position * 192 #+ Vector2(96, 96)
	print("Item position" + str(item_instance.position))
	#player_starting_point = item_instance.position 
	wallsTileMap.add_child(item_instance)

func place_exit_door():
	var ExitDoor: PackedScene = load("res://Level/Exit.tscn")
	var exit = ExitDoor.instance()
	exit.position = player_starting_point
	wallsTileMap.add_child(exit)
	exit_placed = true
	exit.connect("body_entered", self, "on_exit_entered")

func on_right_answer():
	if !exit_placed:
		place_exit_door()

func on_exit_entered(_body):
	get_tree().reload_current_scene()

func get_room_center(of_room: Rect2) -> Vector2:
	return of_room.position + (of_room.size / 2)
