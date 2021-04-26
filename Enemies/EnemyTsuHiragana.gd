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
var wanderController

func _ready():
	self.set_physics_process(false)
	detectionZone = self.get_node("PlayerDetectionZone")
	sprite = self.get_node("Sprite")
	wanderController = self.get_node("WanderController")

func _physics_process(delta):
	
	match state:
		IDLE:
			velocity = Vector2.ZERO
			seek_player()
			if wanderController.get_time_left() == 0:
				state = pick_random_state([IDLE, WANDER], delta)
				wanderController.start_wander_timer(rand_range(1 , 3))
		WANDER:
			seek_player()
			if wanderController.get_time_left() == 0:
				state = pick_random_state([IDLE, WANDER], delta)
				wanderController.start_wander_timer(rand_range(1 , 3))
			var dir: Vector2 = global_position.direction_to(wanderController.target_position)
			velocity = dir * SPEED
			#if global_position.distance_to(wanderController.target_position) <= SPEED / 2:
			#	state = pick_random_state([IDLE, WANDER], delta)
			#	wanderController.start_wander_timer(rand_range(1 , 3))
		CHASE:
			var player = detectionZone.player
			if player != null:
				var dir: Vector2 = global_position.direction_to(player.global_position)#(player.global_position - self.global_position).normalized()
				velocity = dir * SPEED
			else:
				state = IDLE
			sprite.flip_h = velocity.x < 0
	velocity = move_and_slide(velocity)

func seek_player():
	if detectionZone.can_see_player():
		state = CHASE

func pick_random_state(states, delta):
	return states[randi() % 2]

func _on_VisibilityNotifier2D_screen_entered():
	self.set_physics_process(true)


func _on_VisibilityNotifier2D_screen_exited():
	self.set_physics_process(false)
