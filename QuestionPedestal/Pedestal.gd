extends StaticBody2D

enum ANSWER_STATE{
	UNANSWERED = 0,
	RIGHT_ANSWER = 1,
	WRONG_ANSWER = 2
}
onready var sprite = $Sprite
onready var canvaLayer = $CanvasLayer
#onready var question: PackedScene = load("res://QuestionPedestal/ControlQuestion.tscn")

var is_answered: bool = false
var q

func bind_question(question_instance, kana_index: int, possible_answers):
	q = question_instance
	canvaLayer.add_child(q)
	q.randomize_and_fill_answers(kana_index, possible_answers)

func interact_with_player():
	if !is_answered:
		q.show_question()
		var is_right_answer: bool = yield(q, "answer_made")
		is_answered = true
		sprite.frame = ANSWER_STATE.RIGHT_ANSWER if is_right_answer else ANSWER_STATE.WRONG_ANSWER
		print("Interaction occured")
		canvaLayer.queue_free()
		# restore player's health
		PlayerStats.current_health = PlayerStats.max_health

