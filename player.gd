class_name Player
extends CharacterBody2D


@export var movement_speed : float = 120
@export var acceleration : float = 0.6
@export var deceleration : float = 0.1

var elapsed_time : float = 0
var current_speed : float = 0
var was_moving : bool = false


func _physics_process(delta: float) -> void:

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var dir_x := Input.get_axis("ui_left", "ui_right")
	var dir_y := Input.get_axis("ui_up", "ui_down")
	
	var dir := Vector2(dir_x, dir_y).normalized()
	
	var is_moving = dir.length() > 0
	
	elapsed_time += delta
	
	if is_moving:
		var t = clampf(elapsed_time / acceleration, 0,1)
		current_speed = lerpf(0, movement_speed, sin(t))
	else:
		var t = clampf(elapsed_time / deceleration, 0,1)
		current_speed = lerpf(movement_speed, 0, sin(t))
		
	velocity = dir * current_speed
	move_and_slide()
	was_moving = is_moving
