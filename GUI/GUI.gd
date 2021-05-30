extends MarginContainer

onready var kana_label = $Bars/KanaIndicator/KanaBackground/Hieroglyph
onready var number_label = $Bars/LifeBar/Count/HPBackground/Number
onready var bar = $Bars/LifeBar/TextureProgress
onready var tween = $Tween

var animated_health = 0

func _ready():
	$"/root/PlayerStats".connect("health_changed", self, "_on_PlayerStats_health_changed")
	$"/root/PlayerStats".connect("no_health_left", self, "_on_PlayerStats_no_health_left")
	PlayerStats.connect("kana_changed", self, "_on_PlayerStats_kana_changed")
	var player_max_health = $"/root/PlayerStats".max_health
	bar.max_value = player_max_health
	update_health(player_max_health)
	
func _process(delta):
	var round_value = round(animated_health)
	number_label.text = str(round_value)
	bar.value = round_value
	
func update_health(new_value):
	tween.interpolate_property(self, "animated_health", animated_health, new_value, 0.5, Tween.TRANS_LINEAR, Tween.EASE_IN)
	if not tween.is_active():
		tween.start()

func update_kana(new_kana):
	print("new kana is " + str(new_kana))
	#kana_label.text = new_kana

func _on_PlayerStats_health_changed(current_health):
	update_health(current_health)

func _on_PlayerStats_no_health_left():
	var start_color = Color(1.0, 1.0, 1.0, 1.0)
	var end_color = Color(1.0, 1.0, 1.0, 0.0)
	tween.interpolate_property(self, "modulate", start_color, end_color, 1.0, Tween.TRANS_LINEAR, Tween.EASE_IN)

func _on_PlayerStats_kana_changed(new_value):
	update_kana(new_value)
