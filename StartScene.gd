extends Node2D

const QUESTION_NUMBER: int = 3
const ANSWERS_COUNT: int = 3

#onready var canvas_layer = $CanvasLayer

var questions_dictionary = {}

func _ready():
	pass
	#var question_generator = Question_Generator.new()
	#for question in QUESTION_NUMBER:
	#	var kana_index: int = question_generator.get_random_kana_index()
	#	questions_dictionary[kana_index] = question_generator.get_random_answers_for_kana_index(kana_index, ANSWERS_COUNT)
	#question_generator.queue_free()

func _on_LevelRoot_level_generated(starting_pos):
	print("signal emits")
	var player = $PlayerBody
	player.position = starting_pos
