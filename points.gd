class_name Points
extends CharacterBody2D

@export var jump_height : float = 50
@export var jump_peak_time : float = 0.5
@export var jump_fall_time : float = 0.4

@onready var jump_velocity : float = ((2.0 * jump_height) / jump_peak_time) * -1
@onready var jump_gravity : float = ((-2.0 * jump_height) / (jump_peak_time * jump_peak_time)) * -1
@onready var fall_gravity : float = ((-2.0 * jump_height) / (jump_fall_time * jump_fall_time)) * -1

@export var jump_cutoff : float = 10

func _ready() -> void:
	velocity.y = jump_velocity
	$VisibleOnScreenNotifier2D.screen_exited.connect(queue_free)

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

func _get_gravity() -> float:
	return jump_gravity if velocity.y < 0.0 else fall_gravity

func _physics_process(delta: float) -> void:
	velocity.y += _get_gravity() * delta
	move_and_slide()


	
