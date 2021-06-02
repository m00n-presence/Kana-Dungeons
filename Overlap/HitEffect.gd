extends AnimatedSprite

func _ready():
	self.connect("animation_finished", self, "queue_free")

func show_right_kana_effect() -> void:
	if !playing:
		play("right")

func show_wrong_kana_effect() -> void:
	if !playing:
		play("wrong")
