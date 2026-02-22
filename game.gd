extends Node2D

@onready var tiles : TileMapLayer = $Tiles

func _ready() -> void:
	GameManager.tiles = tiles
	GameManager.change_state(GameManager.GAMESTATE.GAME)
	
func check_cycle():
	pass
