extends KinematicBody2D

const SPEED: int = 300
const FRICTION: int = 500
const ACCELERATION: int = 450
const KANA = 9 #ko

enum STATES {
	IDLE,
	WANDER,
	CHASE,
	ATTACK
}

var knockback: Vector2 = Vector2.ZERO
var state = STATES.IDLE
var velocity: Vector2 = Vector2.ZERO

onready var detectionZone = $PlayerDetectionZone
onready var attackZone = $PDZAttack
onready var sprite = $Sprite
onready var wanderController = $WanderController
onready var stats = $Stats
onready var hurtbox = $Hurtbox
var kana_spirit: PackedScene

func _ready():
	self.set_physics_process(false)
	kana_spirit = null # will make spritesheet later

func _physics_process(delta):
	knockback = knockback.move_toward(Vector2.ZERO, FRICTION * delta)
	knockback = move_and_slide(knockback)
	match state:
		STATES.IDLE:
			velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
			seek_player()
			if wanderController.get_time_left() == 0:
				randomize_state_and_start_wander_time()
		STATES.WANDER:
			seek_player()
			if wanderController.get_time_left() == 0:
				randomize_state_and_start_wander_time()
			change_velocity(delta, wanderController.target_position)
			if global_position.distance_to(wanderController.target_position) <= SPEED / 3:
				randomize_state_and_start_wander_time()
		STATES.CHASE:
			var player = detectionZone.player
			if player != null:
				change_velocity(delta, player.global_position)
			else:
				state = STATES.IDLE
	sprite.flip_h = velocity.x < 0
	velocity = move_and_slide(velocity)

func seek_player() -> void:
	if detectionZone.can_see_player():
		state = STATES.CHASE
	elif attackZone.can_see_player():
		state = STATES.ATTACK

func randomize_state_and_start_wander_time() -> void:
	state = STATES.values()[randi() % 2] 
	wanderController.start_wander_timer(rand_range(0 , 2) + 1)

func change_velocity(delta, to_position: Vector2) -> void:
	var dir: Vector2 = global_position.direction_to(to_position)
	velocity = velocity.move_toward(dir * SPEED, ACCELERATION * delta)
