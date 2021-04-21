extends Node2D

signal level_generated(starting_pos)

var borders: Rect2 = Rect2(1, 1, 25, 20)
var player_starting_point = Vector2(13, 10) * 96

onready var wallsTileMap = $WallTileMap
onready var floorTileMap = $FloorTileMap


func _ready():
	randomize()
	generate_level()
	emit_signal("level_generated", player_starting_point)
	

func generate_level():
	var walker = Walker.new(Vector2(13, 10), borders)
	var map = walker.walk_for(300)
	
	
	for location in map:
		wallsTileMap.set_cellv(location, -1)
		floorTileMap.set_cellv(location, 0)
	wallsTileMap.update_bitmask_region(borders.position, borders.end)
	floorTileMap.update_bitmask_region(borders.position, borders.end)
	place_enemies(walker.rooms)
	walker.queue_free()
	#emit_signal("level_generated", player_starting_point)

func place_enemies(rooms_rects):
	var testEnemyScene = preload("res://testEnemy.tscn")
	var length_to_previous_room: int = 0
	var enemy_count: int = 11
	for room in rooms_rects:
		if room.size.x < 2 || room.size.y < 2:
			length_to_previous_room = 0
			continue
		elif randf() <= 0.25:
			length_to_previous_room = 0
			continue
		var tile_position: Vector2 = room.position + room.size / 2
		if tile_position == Vector2(13, 10):
			continue
		var test_enemy = testEnemyScene.instance()
		test_enemy.position = tile_position * 96
		self.add_child(test_enemy)
		length_to_previous_room += 1
		enemy_count -= 1
		if enemy_count <= 0:
			break
		
