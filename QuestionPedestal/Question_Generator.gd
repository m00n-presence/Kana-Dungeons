extends Node
class_name Question_Generator

var hiragana = []
var alphabet_size: int

func _init():
	hiragana = ["a", "i", "u", "e", "o", "ka", "ki", "ku", "ke", "ko"] # continue
	alphabet_size = hiragana.size()

func get_random_kana_index() -> int:
	return randi() % alphabet_size

func get_random_answers_for_kana_index(kana_index: int, total_answers_count: int):
	var answers = []
	answers.append(hiragana[kana_index])
	total_answers_count -= 1
	while total_answers_count > 0:
		var random_answer_kana: String = hiragana[randi() % alphabet_size]
		if !answers.has(random_answer_kana):
			answers.append(random_answer_kana)
			total_answers_count -= 1
	#for answer_index in total_answers_count:
	#	var random_answer_kana: String = hiragana[randi() % alphabet_size]
	#	if !answers.has(random_answer_kana):
	#		answers.append(random_answer_kana)
	return answers
