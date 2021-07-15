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
onready var sprite = $SpritePivot/Sprite
onready var spritePivot = $SpritePivot
onready var wanderController = $WanderController
onready var stats = $Stats
onready var hurtbox = $Hurtbox
onready var hitbox = $Hitbox
onready var hitbox_collision_shape = $Hitbox/CollisionShape2D
onready var attack_anim_timer = $tempAttackAnimTimer
onready var attack_delay_timer = $AttackDelayTimer

var kana_spirit: PackedScene

func _ready():
	self.set_physics_process(false)
	kana_spirit = null # will make spritesheet later
	detectionZone.connect("player_entered_zone", self, "on_DetectionZone_entered")
	attackZone.connect("player_entered_zone", self, "on_AttackZone_entered")
	detectionZone.connect("player_left_zone", self, "on_DetectionZone_left")
	attackZone.connect("player_left_zone", self, "on_AttackZone_left")

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
			if attackZone.can_see_player():
				state = STATES.ATTACK
			else:
				var player = detectionZone.player
				if player != null:
					change_velocity(delta, player.global_position)
				else:
					state = STATES.IDLE
		STATES.ATTACK:
			if attack_anim_timer.is_stopped() && attack_delay_timer.is_stopped():
				var player = attackZone.player
				if player != null:
					make_attack(player)
				else:
					state = STATES.CHASE
	velocity = move_and_slide(velocity)

func seek_player() -> void:
	if attackZone.can_see_player():
		state = STATES.ATTACK
	elif detectionZone.can_see_player():
		state = STATES.CHASE

func randomize_state_and_start_wander_time() -> void:
	state = STATES.values()[randi() % 2] 
	wanderController.start_wander_timer(rand_range(0 , 2) + 1)

func change_velocity(delta, to_position: Vector2) -> void:
	var dir: Vector2 = global_position.direction_to(to_position)
	velocity = velocity.move_toward(dir * SPEED, ACCELERATION * delta)

func make_attack(player_body)-> void:
	velocity = Vector2.ZERO 
	var direction_to_player: Vector2 = global_position.direction_to(player_body.global_position)
	hitbox_collision_shape.set_deferred("disabled", false)
	change_sprite(direction_to_player)
	attack_anim_timer.start(0.5)

func change_sprite(attack_direction: Vector2)-> void:
	if attack_direction == Vector2.ZERO:
		sprite.modulate = Color(1, 1, 1)
		sprite.scale.y = 1
		set_sprite_and_hitbox_rotation(0)
		return
	if abs(attack_direction.x) < abs(attack_direction.y):
		if attack_direction.y < 0:
			set_sprite_and_hitbox_rotation(0)
		else:
			set_sprite_and_hitbox_rotation(180)
	else:
		if attack_direction.x > 0:
			set_sprite_and_hitbox_rotation(90)
		else:
			set_sprite_and_hitbox_rotation(270)
	sprite.modulate = Color(0.760784, 0.019608, 0.019608)
	sprite.scale.y = 1.5

func set_sprite_and_hitbox_rotation(value_in_degrees: float)-> void:
	hitbox.rotation_degrees = value_in_degrees
	spritePivot.rotation_degrees = value_in_degrees

func on_DetectionZone_entered(player_body):
	pass
	#state = STATES.CHASE

func on_AttackZone_entered(player_body):
	pass
	#state = STATES.ATTACK

func on_AttackZone_left():
	return
	if detectionZone.can_see_player():
		state = STATES.CHASE
	else:
		state = STATES.IDLE

func on_DetectionZone_left():
	pass
	#state = STATES.IDLE

func _on_Timer_timeout():
	hitbox_collision_shape.set_deferred("disabled", true)
	change_sprite(Vector2.ZERO)
	state = STATES.CHASE
	attack_delay_timer.start()
