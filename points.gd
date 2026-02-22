class_name Points
extends Node2D

var tween : Tween = null
@export var offset : float = 32
@export var time : float = 0.4

func init(score : int, pos : Vector2):
	global_position = pos
	GameManager.score += score
	GameManager.points_updated.emit()
	match score:
		1:
			$Sprite2D.texture = load("res://tt-uiscore_1.png")
		5:
			$Sprite2D.texture = load("res://tt-uiscore_5.png")
		10:
			$Sprite2D.texture = load("res://tt-uiscore_10.png")
	
	if tween:
		tween.kill()
		
	tween = create_tween()
	tween.tween_property(self, "global_position", global_position + Vector2.UP * offset, time).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN_OUT)
	tween.tween_callback(queue_free)
