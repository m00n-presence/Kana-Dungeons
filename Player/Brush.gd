extends AnimatedSprite

var usual_position : Vector2 

func _ready():
	position = Vector2(-32, -27)
	usual_position = position
	animation = "default"
	rotation_degrees = 0
	show_behind_parent = true

func play_attack_anim(direction : Vector2):
	if (direction.y != 0):
		show_behind_parent = direction.y < 0
		flip_v = direction.y < 0
	elif (direction.x != 0):
		show_behind_parent = true
		rotation_degrees = 90 if direction.x < 0 else 270
		flip_h = true
	change_attacking_position(direction)
	play("attack")


func change_resting_position (direction : Vector2):
	var facing_down_or_right : bool = direction.y > 0 || (direction.y == 0 && direction.x > 0)
	position = usual_position if facing_down_or_right else -usual_position
	show_behind_parent = facing_down_or_right

func change_attacking_position (direction : Vector2):
	if (direction.y != 0):
		position.x = 0
		position.y = 64 if direction.y > 0 else -64
	elif (direction.x != 0):
		position.x = 80 if direction.x > 0 else - 80
		position.y = 13

func attack_finished (direction : Vector2):
	rotation_degrees = 0
	flip_h = false
	flip_v = false
	change_resting_position(direction)
	play("default")

