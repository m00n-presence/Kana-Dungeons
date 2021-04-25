extends KinematicBody2D

const SPEED: int = 150

enum{
	IDLE,
	WANDER,
	CHASE
}

var knockback: Vector2 = Vector2.ZERO
var state = IDLE
var velocity: Vector2 = Vector2.ZERO
var detectionZone
var sprite

func _ready():
	self.set_physics_process(false)
	detectionZone = self.get_node("PlayerDetectionZone")
	sprite = self.get_node("Sprite")

func _physics_process(delta):
	
	
	match state:
		IDLE:
			velocity = Vector2.ZERO
			seek_player()
		WANDER:
			pass
		CHASE:
			var player = detectionZone.player
			if player != null:
				var dir: Vector2 = (player.global_position - self.global_position).normalized()
				velocity = dir * SPEED
			else:
				state = IDLE
			sprite.flip_h = velocity.x < 0
	velocity = move_and_slide(velocity)

func seek_player():
	if detectionZone.can_see_player():
		state = CHASE

func _on_VisibilityNotifier2D_screen_entered():
	self.set_physics_process(true)


func _on_VisibilityNotifier2D_screen_exited():
	self.set_physics_process(false)
