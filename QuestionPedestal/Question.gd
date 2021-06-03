extends MarginContainer

const KANA_COUNT = 45

signal answer_made(is_right)

onready var kanas = $VBoxContainer/SpriteContainer/Control/Sprite
var answer_buttons = []

var right_answer: String = ""

func _ready():
	var buttons = $VBoxContainer/MarginContainer/Buttons
	for child in buttons.get_children():
		answer_buttons.append(child)
		child.connect("pressed", self, "on_answer_pressed", [child])
	hide()
	# for test purposes
	#randomize_and_fill_answers(10, ["sa", "to", "wa"])

func show_question():
	get_tree().paused = true
	show()

func randomize_and_fill_answers(kana_index: int, answers_array) -> void:
	kanas.frame = kana_index
	right_answer = answers_array[0]
	answers_array.shuffle()
	var answer_index: int = 0
	for button in answer_buttons:
		button.text = answers_array[answer_index]
		answer_index += 1

func on_answer_pressed(button):
	if button.text == right_answer:
		print("Your answer was right")
		emit_signal("answer_made", true)
	else:
		var template: String = "Wrong answer, \n this kana reads as '{right_answer}'"
		print(template.format({"right_answer": right_answer}))
		emit_signal("answer_made", false)
	get_tree().paused = false
	queue_free()
