class_name Fireball
extends Node2D

@export var dir : Vector2
@export var shoot_speed : float = 100

func _ready() -> void:
	$VisibleOnScreenNotifier2D.screen_exited.connect(queue_free)

func init(direction : Vector2, speed : float):
	dir = direction
	shoot_speed = speed
	
func _physics_process(delta: float) -> void:
	if GameManager.game_state == GameManager.GAMESTATE.GAMEOVER:
		return
	position += shoot_speed * delta * dir

	var current_tile = GameManager.tiles.local_to_map(position)
	if current_tile == GameManager.tiles.local_to_map(GameManager.player.position):
		GameManager.change_state(GameManager.GAMESTATE.GAMEOVER)
	
	
	
