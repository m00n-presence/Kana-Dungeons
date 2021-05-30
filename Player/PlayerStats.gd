extends "res://Stats.gd"

const DAMAGE_MODIFIER_WRONG_KANA: float = 0.5

export(int) var player_damage = 2
var attack_kana: String = "tsu" setget set_player_attack_kana, get_player_attack_kana

signal kana_changed(new_value)

func _ready():
	max_health = 10
	current_health = max_health

func get_damage_for_kana(kana: String) -> int:
	if (kana == attack_kana):
		return player_damage
	else:
		return player_damage * DAMAGE_MODIFIER_WRONG_KANA

func set_player_attack_kana(value: String):
	attack_kana = value
	emit_signal("kana_changed", value)
	print(attack_kana)

func get_player_attack_kana():
	return attack_kana
