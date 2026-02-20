extends Node2D

@onready var tiles : TileMapLayer = $Tiles

func _ready() -> void:
	print("level loaded")
	GameManager.tiles = tiles
	

func check_cycle():
	pass
