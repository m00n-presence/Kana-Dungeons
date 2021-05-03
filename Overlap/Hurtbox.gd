extends Area2D

var is_invincible: bool = false setget set_invincibility
onready var timer = $Timer

signal invincibility_started
signal invincibility_ended

func set_invincibility(value: bool):
	is_invincible = value
	if is_invincible:
		emit_signal("invincibility_started")
	else:
		emit_signal("invincibility_ended")

func start_invincibility(for_duration: float)-> void:
	self.is_invincible = true
	timer.start(for_duration)

func _on_Timer_timeout():
	self.is_invincible = false

func _on_Hurtbox_invincibility_started():
	set_deferred("monitoring", false)

func _on_Hurtbox_invincibility_ended():
	monitoring = true
