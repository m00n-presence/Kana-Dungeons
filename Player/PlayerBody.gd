extends KinematicBody2D

const WALKING_SPEED : int = 275
const ROLLING_SPEED : int = 450

var velocity : Vector2 = Vector2.ZERO
var directionVector : Vector2 = Vector2.DOWN

enum {
	MOVE,
	ATTACK,
	ROLL,
	INTERACT
}
var currentState = MOVE

onready var animationTree = $AnimationTree
onready var animationState = animationTree.get("parameters/playback")
onready var brushSprite = $BrushSprite
onready var rayCast = $RayCast2D

func _ready():
	animationTree.active = true
	self.position = Vector2(13, 10) * 96
	rayCast.rotation_degrees = 0
	rayCast.enabled = false

func _physics_process(delta):
	match currentState:
		MOVE:
			move(delta)
		ATTACK:
			attack(delta)
		ROLL:
			roll(delta)
		INTERACT:
			interact(delta)
	
func move(_delta):
	var input_Vector = Vector2.ZERO
	input_Vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input_Vector.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	input_Vector = input_Vector.normalized()
	
	if input_Vector != Vector2.ZERO:
		directionVector = input_Vector
		brushSprite.change_resting_position(directionVector)
		animationTree.set("parameters/Idle/blend_position", input_Vector)
		animationTree.set("parameters/Go/blend_position", input_Vector)
		animationTree.set("parameters/Attack/blend_position", input_Vector)
		animationTree.set("parameters/Roll/blend_position", input_Vector)
		animationState.travel("Go")
	else:
		animationState.travel("Idle")
		#$CollisionShape2D.position.x = 2
	
	velocity = input_Vector * WALKING_SPEED 
	velocity = move_and_slide(velocity) #velocity = ???
	
	if (Input.is_action_just_pressed("attack")):
		currentState = ATTACK
	elif (Input.is_action_just_pressed("roll")):
		currentState = ROLL
	elif (Input.is_action_just_pressed("ui_select")):
		currentState = INTERACT
	#$CollisionShape2D.position = Vector2(2, 68)

func attack(_delta):
	brushSprite.play_attack_anim(directionVector)
	animationState.travel("Attack")

func roll(_delta):
	velocity = directionVector * ROLLING_SPEED
	animationState.travel("Roll")
	velocity = move_and_slide(velocity)

func on_attack_animation_finished():
	currentState = MOVE
	brushSprite.attack_finished(directionVector)	

func on_roll_animation_finished():
	currentState = MOVE

func change_raycast_length(facing_vertical: bool):
	if (facing_vertical):
		rayCast.cast_to.y = 100
	else:
		rayCast.cast_to.y = 60

func interact(_delta):
	animationState.travel("Idle")
	rayCast.force_raycast_update()
	var collider = rayCast.get_collider()
	if (collider != null):
		if (collider.is_in_group("pedestals")):
			collider.interact_with_player()
	currentState = MOVE
	

