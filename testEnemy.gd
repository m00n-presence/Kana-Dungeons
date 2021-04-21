extends Sprite

func _ready():
	self.set_physics_process(false)

func _physics_process(_delta):
	if (Input.is_action_just_pressed("ui_accept")):
		print("hi")
	

func _on_Area2D_body_entered(body):
	if (body.is_in_group("player")):
		self.set_physics_process(true)
		print("interacting")


func _on_Area2D_body_exited(body):
	if (body.is_in_group("player")):
		self.set_physics_process(false)
		print("exited")
