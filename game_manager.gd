extends Node2D

@export var tiles : TileMapLayer


const YELLOW_TILE : Vector2i = Vector2(4,2)
const BLACK_TILE : Vector2i = Vector2(3,2)
const FLOOR_TILE : Vector2i = Vector2(2,2)
const WALL_TILE : Vector2i = Vector2(1,2)
const VALID_FLOORS : Array[Vector2i] = [YELLOW_TILE, BLACK_TILE, FLOOR_TILE]
