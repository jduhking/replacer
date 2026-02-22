class_name MainCamera
extends Camera2D

var shake_strength : float = 0.0
var shake_decay : float = 5.0

func _ready() -> void: 
	GameManager.cam = self

func shake(strength : float, decay : float):
	shake_strength = strength
	shake_decay = decay

func _process(delta: float) -> void:
	if shake_strength > 0:
		shake_strength = lerpf(shake_strength, 0.0, shake_decay * delta)
		offset = Vector2(
			randf_range(-shake_strength, shake_strength),
			randf_range(-shake_strength, shake_strength)
		)
	else:
		offset = Vector2.ZERO
