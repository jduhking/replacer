extends Control

@onready var blink_label : Label = $ColorRect/VBoxContainer/startText  # adjust path
var started : bool = false
func _ready():
	$ColorRect/VBoxContainer/startText/Timer.start()

func _on_timer_timeout():
	if blink_label.modulate.a == 1.0:
		blink_label.modulate.a = 0.0
	else:
		blink_label.modulate.a = 1.0
		
func _process(delta: float) -> void:
	if Input.is_anything_pressed():
		started = true
		_on_start_pressed()

func _on_start_pressed():
	GameManager.call_deferred("_deferred_goto_scene","res://game.tscn")
