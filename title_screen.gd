extends Control

@onready var blink_label : Label = $ColorRect/VBoxContainer/startText  # adjust path

func _ready():
	$ColorRect/VBoxContainer/startText/Timer.start()

func _on_timer_timeout():
	if blink_label.modulate.a == 1.0:
		blink_label.modulate.a = 0.0
	else:
		blink_label.modulate.a = 1.0
