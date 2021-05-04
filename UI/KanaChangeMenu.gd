extends Sprite

var is_in_pause_mode: bool = false
var kanas = {
	Vector2(1,1): "n",
	Vector2(2,1): "wa",
	Vector2(3,1): "ra",
	Vector2(11,1): "a",
	Vector2(8,3): "tsu"
}
# append remaining letters

onready var tiles = $TileMap

func _ready():
	is_in_pause_mode = false
	self.hide()

func _input(event):
	if is_in_pause_mode && event is InputEventMouseButton && event.is_pressed():
		var local_mouse_pos: Vector2 = get_local_mouse_position()
		var tile_position: Vector2 = tiles.world_to_map(local_mouse_pos)
		if kanas.has(tile_position):
			PlayerStats.attack_kana = kanas[tile_position]
			exit_pause_mode()
	elif event.is_action_pressed("pause"):
		if is_in_pause_mode:
			exit_pause_mode()
		else:
			enter_pause_mode()

func enter_pause_mode():
	get_tree().paused = true
	is_in_pause_mode = true
	print("entered pause")
	self.show()

func exit_pause_mode():
	self.hide()
	is_in_pause_mode = false
	get_tree().paused = false
	print("pause exited")
