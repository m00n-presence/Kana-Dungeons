extends Area2D

#export(bool) var show_hit_effect = true

var is_invincible: bool = false setget set_invincibility

onready var Hit_Effect: PackedScene = preload("res://Overlap/HitEffect.tscn")
onready var timer = $Timer

signal invincibility_started
signal invincibility_ended

func show_hit_effect(is_attack_kana_right = false):
	#if (show_hit_effect):
	var hit_effect = Hit_Effect.instance()
	hit_effect.global_position = global_position
	get_parent().get_parent().add_child(hit_effect)
	if (is_attack_kana_right):
		hit_effect.show_right_kana_effect()
	else:
		hit_effect.show_wrong_kana_effect()

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
