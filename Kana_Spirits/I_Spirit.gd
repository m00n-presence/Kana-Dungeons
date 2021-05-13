extends AnimatedSprite

func _ready():
	play("default")

func _on_Area2D_body_entered(body):
	if playing:
		frame = 0
		play("default")
