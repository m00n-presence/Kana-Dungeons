extends TextureRect

const X_SIZE: int = 150
const Y_SIZE: int = 170

var is_in_pause_mode: bool = false
var kanas = {
	Vector2(11,1): 0,
	Vector2(11,2): 1,
	Vector2(11,3): 2,
	Vector2(11,4): 3,
	Vector2(11,5): 4,
	Vector2(10,1): 5,
	Vector2(10,2): 6,
	Vector2(10,3): 7,
	Vector2(10,4): 8,
	Vector2(10,5): 9,
	Vector2(9,1): 10,
	Vector2(9,2): 11,
	Vector2(9,3): 12,
	Vector2(9,4): 13,
	Vector2(9,5): 14,
	Vector2(8,1): 15,
	Vector2(8,2): 16,
	Vector2(8,3): 17,
	Vector2(8,4): 18,
	Vector2(8,5): 19,	
	Vector2(7,1): 20,
	Vector2(7,2): 21,
	Vector2(7,3): 22,
	Vector2(7,4): 23,
	Vector2(7,5): 24,
	Vector2(6,1): 25,
	Vector2(6,2): 26,
	Vector2(6,3): 27,
	Vector2(6,4): 28,
	Vector2(6,5): 29,
	Vector2(5,1): 30,
	Vector2(5,2): 31,
	Vector2(5,3): 32,
	Vector2(5,4): 33,
	Vector2(5,5): 34,
	Vector2(4,1): 35,
	Vector2(4,3): 36,
	Vector2(4,5): 37,
	Vector2(3,1): 38,
	Vector2(3,2): 39,
	Vector2(3,3): 40,
	Vector2(3,4): 41,
	Vector2(3,5): 42,
	Vector2(2,1): 43,
	Vector2(2,5): 44,
	Vector2(1,1): 45
}
# append remaining letters

onready var texture_size_x: int = texture.get_size().x

var x_side: float = X_SIZE
var y_side: float = Y_SIZE

func _ready():
	is_in_pause_mode = false
	self.connect("resized", self, "on_resize")
	on_resize()
	self.hide()

func _input(event):
	if is_in_pause_mode && event is InputEventMouseButton && event.is_pressed():
		var local_mouse_pos: Vector2 = get_local_mouse_position()
		var tile_position: Vector2 = get_letter_vector_from_mouse_pos(local_mouse_pos)#tiles.world_to_map(local_mouse_pos)
		if kanas.has(tile_position):
			PlayerStats.attack_kana = kanas[tile_position]
			exit_pause_mode()
	elif event.is_action_pressed("pause"):
		if is_in_pause_mode:
			exit_pause_mode()
		else:
			enter_pause_mode()

func enter_pause_mode():
	var tree = get_tree()
	if tree.paused:
		return
	tree.paused = true
	is_in_pause_mode = true
	self.show()

func exit_pause_mode():
	self.hide()
	is_in_pause_mode = false
	get_tree().paused = false

func on_resize():
	var new_scale: float = rect_size.x / texture_size_x
	x_side = ceil(X_SIZE * new_scale)
	y_side = ceil(Y_SIZE * new_scale)

func get_letter_vector_from_mouse_pos(mouse_pos: Vector2) -> Vector2:
	var x : int = floor(mouse_pos.x / x_side)
	var y : int = floor(mouse_pos.y / y_side)
	return Vector2(x, y)
