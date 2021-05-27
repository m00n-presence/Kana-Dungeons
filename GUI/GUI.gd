extends MarginContainer

onready var number_label = $Bars/LifeBar/Count/Background/Number
onready var bar = $Bars/LifeBar/TextureProgress
onready var tween = $Tween

var animated_health = 0

func _ready():
	var player_max_health = $"/root/PlayerStats".max_health
	bar.max_value = player_max_health
	update_health(player_max_health)
	
func _process(delta):
	var round_value = round(animated_health)
	number_label.text = str(round_value)
	bar.value = round_value
	
func update_health(health):
	tween.interpolate_property(self, "animated_health", animated_health, health, 0.5, Tween.TRANS_LINEAR, Tween.EASE_IN)
	if not tween.is_active():
		tween.start()

func _on_PlayerStats_health_changed(current_health):
	update_health(current_health)

func _on_PlayerStats_no_health_left():
	var start_color = Color(1.0, 1.0, 1.0, 1.0)
	var end_color = Color(1.0, 1.0, 1.0, 0.0)
	tween.interpolate_property(self, "modulate", start_color, end_color, 1.0, Tween.TRANS_LINEAR, Tween.EASE_IN)

