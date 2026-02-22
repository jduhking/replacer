extends Control

@onready var blink_label : Label = $ColorRect/VBoxContainer/startText  # adjust path
var started : bool = false
@onready var title_screen_music : AudioStreamPlayer2D = $TitleScreenMusic
@onready var proceed : AudioStreamPlayer2D	= $Proceed

var tween : Tween 
func _ready():
	title_screen_music.play()
	$ColorRect/VBoxContainer/startText/Timer.start()
	
	
func _transition():
	if tween:
		tween.kill()
	tween = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(UIManager.cutout_transition, "modulate:a", 1.0, 0.8)
	
	tween.tween_callback(GameManager.call_deferred.bind("_deferred_goto_scene","res://game.tscn"))
func _on_timer_timeout():
	if blink_label.modulate.a == 1.0:
		blink_label.modulate.a = 0.0
	else:
		blink_label.modulate.a = 1.0
		
func _process(delta: float) -> void:
	if Input.is_anything_pressed() and !started:
		started = true
		title_screen_music.stop()
		_on_start_pressed()
		proceed.play()

func _on_start_pressed():
	_transition()
