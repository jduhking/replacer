extends Node2D

@onready var tiles : TileMapLayer = $Tiles

@onready var game_theme : AudioStreamPlayer2D = $GameTheme

func _ready() -> void:
	GameManager.tiles = tiles
	GameManager.change_state(GameManager.GAMESTATE.GAME)
	game_theme.play()
func check_cycle():
	pass
