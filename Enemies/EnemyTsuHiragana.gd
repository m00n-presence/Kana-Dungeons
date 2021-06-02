extends KinematicBody2D

const SPEED: int = 150
const FRICTION: int = 400
const ACCELERATION: int = 400
const KANA = 17 #"tsu"

enum STATES {
	IDLE,
	WANDER,
	CHASE
}

var knockback: Vector2 = Vector2.ZERO
var state = STATES.IDLE
var velocity: Vector2 = Vector2.ZERO

onready var detectionZone = $PlayerDetectionZone
onready var sprite = $Sprite
onready var wanderController = $WanderController
onready var stats = $Stats
onready var hurtbox = $Hurtbox
var kana_spirit: PackedScene


func _ready():
	self.set_physics_process(false)
	kana_spirit = load("res://Kana_Spirits/Tsu.tscn")
	sprite.play("default")

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
			if global_position.distance_to(wanderController.target_position) <= SPEED / 2:
				randomize_state_and_start_wander_time()
		STATES.CHASE:
			var player = detectionZone.player
			if player != null:
				change_velocity(delta, player.global_position)
			else:
				state = STATES.IDLE
	sprite.flip_h = velocity.x < 0
	velocity = move_and_slide(velocity)

func seek_player():
	if detectionZone.can_see_player():
		state = STATES.CHASE

func pick_random_state(states):
	return states[randi() % 2]

func change_velocity(delta, to_position: Vector2) -> void:
	var dir: Vector2 = global_position.direction_to(to_position)
	velocity = velocity.move_toward(dir * SPEED, ACCELERATION * delta)

func randomize_state_and_start_wander_time() -> void:
	state = STATES.values()[randi() % 2] 
	wanderController.start_wander_timer(rand_range(1 , 3))

func _on_Hurtbox_area_entered(area):
	knockback = area.knockback_vector * 475
	hurtbox.show_hit_effect(KANA == PlayerStats.attack_kana)
	stats.current_health -= PlayerStats.get_damage_for_kana(KANA)
	#print(stats.current_health)

func _on_Stats_no_health_left():
	var parent = self.get_parent()
	var tsu_spirit = kana_spirit.instance()
	tsu_spirit.position = self.position
	parent.call_deferred("add_child", tsu_spirit)
	self.queue_free()
