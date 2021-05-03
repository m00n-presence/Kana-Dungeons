extends "res://Stats.gd"

const DAMAGE_MODIFIER_WRONG_KANA: float = 0.5

export(int) var player_damage = 2 
var attack_kana: String = "tsu" 

func get_damage_for_kana(kana: String) -> int:
	if (kana == attack_kana):
		return player_damage
	else:
		return player_damage * DAMAGE_MODIFIER_WRONG_KANA
