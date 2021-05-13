extends StaticBody2D

const KANA: String = "i"

var can_interact: bool = false

func interact_with_player():
	if can_interact:
		print("can interact")
		PlayerStats.player_damage += 1
		queue_free()
	else:
		print("can't interact")

func _on_Hurtbox_area_entered(area):
	if PlayerStats.attack_kana == KANA:
		can_interact = true
		$Hurtbox.set_deferred("monitoring", false)
