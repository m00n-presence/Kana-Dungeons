extends Area2D

export(String) var kana_to_show = "."
export(String) var association_object = "."
onready var textLabel = $Label
onready var timer = $Timer

var text = " How to read: {kana}\n Association: {association}"

func _ready():
	textLabel.hide()
	textLabel.text = text.format({"kana": kana_to_show, "association": association_object})

func _on_Timer_timeout():
	textLabel.hide()

func _on_Area2D_body_entered(body):
	textLabel.show()
	if timer.time_left > 0:
		timer.stop()

func _on_Area2D_body_exited(body):
	timer.start(3)
