extends Enemy


var shoot_direction : Vector2i
const min_shoot_speed : float = 45
const max_shoot_speed : float = 200

var fireball := preload("res://Enemies/fireball.tscn")

func aim_player():
	var tilemap : TileMapLayer = GameManager.tiles
	var current_tile = tilemap.local_to_map(position)
	var player_tile = tilemap.local_to_map(GameManager.player.position)
	var dir = player_tile - current_tile
	shoot_direction = Vector2i(sign(dir.x), sign(dir.y))
	
func shoot():
	var tilemap : TileMapLayer = GameManager.tiles
	var current_tile = tilemap.local_to_map(position)
	var speed = randf_range(min_shoot_speed, max_shoot_speed)
	var game = get_parent()
	var fb : Fireball = fireball.instantiate()
	var spawn_point = tilemap.map_to_local(current_tile + shoot_direction * GameManager.CELL_SIZE)
	fb.position = spawn_point
	fb.init(shoot_direction, speed)
	game.add_child(fb)
	
