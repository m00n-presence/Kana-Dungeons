extends Area2D

export(String) var kana_to_show = "."
export(String) var association_object = "."

onready var textLabel: Label = $Label
onready var timer: Timer = $Timer
onready var letter_sprite: AnimatedSprite = $LetterAnim

var phrase: String = " Как читается: {kana} \n Ассоциация: {association} "

# Эту функцию нужно вызвать до того, как эта сцена станет чьим-то наследником
# letter - прочтение слога
func set_up(letter: String, association_obj: String) -> void:
	_prepare_letter_animation(letter)
	_prepare_info_template(letter, association_obj)

# Подготавливает текст на табличке
func _prepare_info_template(letter: String, association_obj: String) -> void:
	textLabel.text = phrase.format({"kana": letter, "association": association_obj})
	#textLabel.hide()
	#textLabel.show()
	textLabel.rect_size = textLabel.rect_min_size
	textLabel.get_node("ColorRect").rect_size = textLabel.rect_size
	textLabel.show()

# Подготавливает анимацию написания буквы
# !! ВАЖНО !! пути до spriteframes ресурсов включают транскрипцию буквы letter строчными английскими буквами.
func _prepare_letter_animation(letter: String) -> void:
	letter = letter.to_lower()
	var frames_path: String = "res://Kana_Spirits/spirit_frames_res/" + letter + "_frames.tres"
	var file_check: File = File.new()
	if file_check.file_exists(frames_path):
		var frames_res: SpriteFrames = load(frames_path)
		letter_sprite.frames = frames_res
		letter_sprite.play("default")

func _on_Timer_timeout():
	textLabel.hide()

func _on_Area2D_body_entered(_body):
	textLabel.show()
	if timer != null && timer.time_left > 0:
		timer.stop()
	if letter_sprite != null && letter_sprite.frames != null && letter_sprite.playing:
		letter_sprite.frame = 0
		letter_sprite.play("default")

func _on_Area2D_body_exited(_body):
	if timer != null:
		timer.start(3)
