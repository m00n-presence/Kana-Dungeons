extends Node2D

export(int) var wander_range = 50

onready var starting_position: Vector2 = self.global_position
onready var timer = $Timer

onready var target_position: Vector2 = self.global_position

func update_target_position() -> void:
	var target_vector: Vector2 = Vector2(rand_range(-wander_range, wander_range), rand_range(-wander_range, wander_range))
	target_position = starting_position + target_vector

func get_time_left():
	return timer.time_left

func start_wander_timer(duration: int) -> void:
	timer.start(duration)

func _on_Timer_timeout():
	update_target_position()
