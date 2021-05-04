extends Sprite

var kanas = {
	Vector2(1,1): "n",
	Vector2(2,1): "wa",
	Vector2(3,1): "ra",
	Vector2(11,1): "a",
	Vector2(8,3): "tsu"
}

onready var tiles = $TileMap

func _ready():
	pass # Replace with function body.

func _input(event):
	if event.is_pressed() && event is InputEventMouseButton:
		var local_mouse_pos: Vector2 = get_local_mouse_position()
		var tile_position: Vector2 = tiles.world_to_map(local_mouse_pos)
		if kanas.has(tile_position):
			print(kanas[tile_position])
