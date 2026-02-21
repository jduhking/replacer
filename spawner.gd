class_name Spawner
extends Node2D

enum STATE { FOLLOW, SPAWN, STOP }
var current_state : STATE = STATE.STOP
var elapsed_time: float = 0
@export var spawn_follow_time : float = 5
@export var spawn_time : float = 0.4
var grid_position : Vector2i = Vector2i.ZERO
@export var follow_offset : Vector2 = Vector2(-2,0)

@export var black : Color
@export var yellow : Color
# Hello James was here.
var enemy_map = { "basic" : preload("res://Enemies/normal-enemy.tscn"), "ranged" : preload("res://Enemies/ranged-enemy.tscn")}
var spawn_percentage_map = { "basic" : 0.8, "ranged" : 0.2}
# Called when the node enters the scene tree for the first time.
var color : GameManager.PAINT = GameManager.PAINT.YELLOW
@onready var color_map = { GameManager.PAINT.YELLOW : yellow, GameManager.PAINT.BLACK : black }

var random_spawn_time : float = 6
var random_spawn_elapsed_time : float = 0

var spawning_random : bool = false
var random_spawn_still_time : float = 1
var still_elapsed_time : float = 0
var random_grid_pos : Vector2i

func _ready() -> void:
	change_state(STATE.FOLLOW)
	

func change_state(new_state : STATE):
	current_state = new_state
	elapsed_time = 0
	match new_state:
		STATE.FOLLOW:
			pass
		STATE.SPAWN:
			pass
		STATE.STOP:
			pass
			
func update_state(delta : float):
	match current_state:
		STATE.FOLLOW:
			elapsed_time += delta
			follow_player()
			if elapsed_time >= spawn_follow_time:
				change_state(STATE.SPAWN)
		STATE.SPAWN:
			elapsed_time += delta
			if elapsed_time >= spawn_time:
				spawn_enemy("basic", grid_position)
				change_state(STATE.FOLLOW)
		STATE.STOP:
			pass
			
			
func follow_player():
	global_position = GameManager.player.global_position + follow_offset
	grid_position = GameManager.tiles.local_to_map(GameManager.player.position)
	
func spawn_enemy(enemy_name : String, grid_pos : Vector2i):
	var enemy : Enemy = (enemy_map[enemy_name] as PackedScene).instantiate()
	enemy.paint = color
	var tilemap = GameManager.tiles
	var enemy_spawn_location = tilemap.map_to_local(grid_pos) 
	#print("enemy spawning here: ", enemy_spawn_location)
	enemy.global_position = Vector2(enemy_spawn_location)
	get_parent().add_child(enemy)
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var tilemap : TileMapLayer = GameManager.tiles
	var atlas = tilemap.get_cell_atlas_coords(grid_position)
	color = GameManager.PAINT.YELLOW if atlas == GameManager.YELLOW_TILE else (GameManager.PAINT.BLACK if atlas == GameManager.BLACK_TILE else color)
	$ColorRect.color = color_map[color]
	queue_redraw()
	
func _physics_process(delta: float) -> void:
	if not spawning_random:
		random_spawn_elapsed_time += delta
		if random_spawn_elapsed_time >= random_spawn_time:
			random_spawn_elapsed_time = 0
			var keys = GameManager.painted_cells.keys()
			var random_key = keys[randi() % keys.size()]
			random_grid_pos = random_key
			spawning_random = true
	else:
		still_elapsed_time += delta
		if still_elapsed_time >= random_spawn_still_time:
			still_elapsed_time = 0
			spawning_random = false
			spawn_enemy("basic", random_grid_pos)
	update_state(delta)
	
func _draw() -> void:
	var tilemap = GameManager.tiles
	if tilemap == null:
		return
	var cell_world_pos = tilemap.map_to_local(grid_position)
	var top_left = cell_world_pos - Vector2(8, 8) - global_position
	draw_rect(Rect2(top_left, Vector2(16, 16)), Color.RED, false, 1.0)
	
	if spawning_random:
		var cwp = tilemap.map_to_local(random_grid_pos)
		var tl = cwp - Vector2(8, 8) - global_position
		draw_rect(Rect2(tl, Vector2(16, 16)), Color.RED, false, 1.0)
