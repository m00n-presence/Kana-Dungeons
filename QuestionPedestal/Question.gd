extends ColorRect

const KANA_COUNT = 45

onready var kanas = $Sprite
var answer_buttons = []

var right_answer: String = ""

func _ready():
	for button in get_tree().get_nodes_in_group("AnswerButtons"):
		answer_buttons.append(button)
		button.connect("pressed", self, "on_answer_pressed", [button])
	# for test purposes
	randomize_and_fill_answers(10, ["sa", "to", "wa"])

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
	else:
		var template: String = "Wrong answer, \n this kana reads as '{right_answer}'"
		print(template.format({"right_answer": right_answer}))
	queue_free()
