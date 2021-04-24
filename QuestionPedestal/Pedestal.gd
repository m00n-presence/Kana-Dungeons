extends StaticBody2D

onready var sprite = $Sprite

func interact_with_player():
	if (sprite.frame == 2):
		sprite.frame = 0
	else:
		sprite.frame += 1
	print("Interaction occured")

