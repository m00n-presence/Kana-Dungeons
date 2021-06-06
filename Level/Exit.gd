extends Area2D

func _on_Timer_timeout():
	var layer = $CanvasLayer
	if layer != null:
		layer.queue_free()
