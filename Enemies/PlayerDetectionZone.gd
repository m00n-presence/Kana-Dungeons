extends Area2D

signal player_entered_zone(player_body)
signal player_left_zone

var player = null

func _on_PlayerDetectionZone_body_entered(body):
	player = body
	emit_signal("player_entered_zone", player)

func _on_PlayerDetectionZone_body_exited(_body):
	player = null
	emit_signal("player_left_zone")

func can_see_player() -> bool:
	return player != null
