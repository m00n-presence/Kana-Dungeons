extends Node2D


var lvl;
# Called when the node enters the scene tree for the first time.
func _ready():
	lvl = $LevelRoot
	#lvl.connect("level_generated", self, "on_level_created" )


func _on_LevelRoot_level_generated(starting_pos):
	print("signal emits")
	var player = $LevelRoot/WallTileMap/PlayerBody
	player.position = starting_pos
