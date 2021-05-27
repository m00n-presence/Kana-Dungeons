extends "res://Stats.gd"

const DAMAGE_MODIFIER_WRONG_KANA: float = 0.5

export(int) var player_damage = 2 
var attack_kana = 0 setget set_player_attack_kana, get_player_attack_kana #"tsu"

func _ready():
	max_health = 10
	current_health = max_health

func get_damage_for_kana(kana) -> int:
	if (kana == attack_kana):
		return player_damage
	else:
		return player_damage * DAMAGE_MODIFIER_WRONG_KANA

func set_player_attack_kana(value):
	attack_kana = value
	print(attack_kana)

func get_player_attack_kana():
	return attack_kana
