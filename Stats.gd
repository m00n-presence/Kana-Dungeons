extends Node

export(int) var max_health = 1
onready var current_health: int = max_health setget set_current_health, get_current_health

signal no_health_left
signal health_changed

func set_current_health(value: int):
	current_health = value
	print(current_health)
	emit_signal("health_changed", current_health)
	if current_health <= 0:
		current_health = 0
		emit_signal("no_health_left")
	

func get_current_health() -> int:
	return current_health
 
