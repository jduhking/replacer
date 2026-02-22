class_name Spawner
extends Node2D

enum STATE { FOLLOW, SPAWN, STOP }
var current_state : STATE = STATE.STOP
var elapsed_time: float = 0
@export var spawn_follow_time : float = 5
@export var spawn_time : float = 0.4
var grid_position : Vector2i = Vector2i.ZERO
@export var follow_offset : Vector2 = Vector2(-2,0)
@export var spawn_indicator : Texture2D

var enemy_map = { "basic" : preload("res://Enemies/normal-enemy.tscn"), "ranged" : preload("res://Enemies/ranged-enemy.tscn"), "elite" : preload("res://Enemies/elite_enemy.tscn")}
@export var default_basic_percentage : float = 0.6
@export var default_ranged_percentage : float = 0.3
@export var default_elite_percentage : float = 0.1
@onready var default_percent_map = { "basic" : default_basic_percentage, "ranged" : default_ranged_percentage, "elite" : default_elite_percentage }

@onready var enemy_percent_map = default_percent_map
# Called when the node enters the scene tree for the first time.
var color : GameManager.PAINT = GameManager.PAINT.YELLOW


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
				spawn_enemy(select_enemy(), grid_position)
				change_state(STATE.FOLLOW)
		STATE.STOP:
			pass
			
			
func follow_player():
	global_position = GameManager.player.global_position + follow_offset
	grid_position = GameManager.tiles.local_to_map(GameManager.player.position)
	
func select_enemy():
	var rand_val = randf()
	var acc = 0.0
	for key in enemy_percent_map.keys():
		acc += enemy_percent_map[key]
		if rand_val < acc:
			return key
			
	return enemy_percent_map.keys()[-1]  # fallback to last
	
func spawn_enemy(enemy_name : String, grid_pos : Vector2i):
	var enemy : Enemy = (enemy_map[enemy_name] as PackedScene).instantiate()
	enemy.paint = color
	var enemy_spawn_location = GameManager.tiles.map_to_local(grid_pos) 
	#print("enemy spawning here: ", enemy_spawn_location)
	enemy.global_position = Vector2(enemy_spawn_location)
	get_parent().add_child(enemy)
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var atlas = GameManager.tiles.get_cell_atlas_coords(grid_position)
	color = GameManager.PAINT.YELLOW if atlas == GameManager.YELLOW_TILE else (GameManager.PAINT.BLACK if atlas == GameManager.BLACK_TILE else color)
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
	if GameManager.tiles == null:
		return
	var cell_world_pos = GameManager.tiles.map_to_local(grid_position)
	#var top_left = cell_world_pos - Vector2(8, 8) - global_position
	draw_texture(spawn_indicator, cell_world_pos - Vector2(8, 8) - global_position)
	
	if spawning_random:
		var cwp = GameManager.tiles.map_to_local(random_grid_pos)
		var tl = cwp - Vector2(8, 8)
		draw_texture(spawn_indicator, tl - global_position)
