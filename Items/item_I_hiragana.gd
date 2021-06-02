extends StaticBody2D

const KANA = 1 #"i"

onready var hurtbox = $Hurtbox

var can_interact: bool = false

func interact_with_player():
	if can_interact:
		print("can interact")
		PlayerStats.player_damage += 1
		var spirit = load("res://Kana_Spirits/I_Spirit.tscn").instance()
		spirit.position = position
		get_parent().add_child(spirit)
		queue_free()
	else:
		print("can't interact")

func _on_Hurtbox_area_entered(area):
	var is_right_kana: bool = PlayerStats.attack_kana == KANA
	hurtbox.show_hit_effect(is_right_kana)
	if is_right_kana:
		can_interact = true
		$Hurtbox.set_deferred("monitoring", false)
