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
	global_position += shoot_speed * delta * dir
	var tilemap : TileMapLayer = GameManager.tiles
	var current_tile = tilemap.local_to_map(position)
	if current_tile == tilemap.local_to_map(GameManager.player.position):
		GameManager.change_state(GameManager.GAMESTATE.GAMEOVER)
	
	
	
