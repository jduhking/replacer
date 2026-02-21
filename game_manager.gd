extends Node2D

@export var tiles : TileMapLayer
@export var font : Font

enum PAINT { YELLOW, BLACK }
enum GAMESTATE { NONE, GAME, GAMEOVER }
var game_state : GAMESTATE = GAMESTATE.GAME

const game_path = "res://game.tscn"

const CELL_SIZE = 16;
const COLS := int(256 / CELL_SIZE)
const ROWS := int(224 / CELL_SIZE)


const YELLOW_TILE : Vector2i = Vector2i(6,2)
const BLACK_TILE : Vector2i = Vector2i(6,6)
const FLOOR_TILE : Vector2i = Vector2i(6,10)
const WALL_TILE : Vector2i = Vector2i(3,10)

var player : Player

var paint_to_atlas_map = { PAINT.YELLOW : YELLOW_TILE , PAINT.BLACK : BLACK_TILE }
var current_scene 
const directions = [
		Vector2i(-1,-1), Vector2i(1,-1),
		Vector2i(-1,1), Vector2i(1,1),
		Vector2i.UP, Vector2i.DOWN,
		Vector2i.LEFT, Vector2i.RIGHT
	]

var costs_yellow : Array[float] = []
var costs_black : Array[float] = []
var flows_yellow : Array[Vector2i] = []
var flows_black : Array[Vector2i] = []

var reserved_cells : Dictionary = {}

#const VALID_FLOORS : Array[Vector2i] = [YELLOW_TILE, BLACK_TILE, FLOOR_TILE]

#func _ready():
	#await get_tree().process_frame
	#

@export var game_over_time : float = 8

func change_state(new_state : GAMESTATE):
	game_state = new_state
	match game_state:
		GAMESTATE.GAME:
			get_tree().paused = false
		GAMESTATE.GAMEOVER:
			get_tree().paused = true
			UIManager.set_gameover_label(true)
			await get_tree().create_timer(game_over_time).timeout
			UIManager.set_gameover_label(false)
			restart_level()

func _process(delta: float) -> void:
	update_state(delta)
			
func update_state(delta):
	match game_state:
		GAMESTATE.GAME:
			pass
			#if Input.is_action_just_pressed("toggle"):
				#change_state(GameManager.GAMESTATE.GAMEOVER)
			
func restart_level():
	call_deferred("_deferred_goto_scene", game_path)
	
func _deferred_goto_scene(path):
	var scene_tree = get_tree().current_scene
	if scene_tree != null:
		scene_tree.free()
		
	var s = ResourceLoader.load(path)
	current_scene = s.instantiate()
	get_tree().root.add_child(current_scene)
	get_tree().current_scene = current_scene
	change_state(GameManager.GAMESTATE.GAME)
			
func build_heat_map(player_cell : Vector2i, color : PAINT):
	var costs : Array[float] = costs_black if color == PAINT.BLACK else costs_yellow
	costs.resize(ROWS * COLS)
	costs.fill(INF)
	var visited : Array[bool] = []
	visited.resize(ROWS * COLS)
	visited.fill(false)
	var queue : Array[Vector2i] = [player_cell]
	costs[player_cell.y * COLS + player_cell.x] = 0
	while queue.size() > 0:
		var current : Vector2i = queue.pop_front()
		var current_idx = current.y * COLS + current.x
		if visited[current_idx]:
			continue
		visited[current_idx] = true
		var current_cost = costs[current_idx]
		for neigh in get_neighbors(current, color):
			var idx = neigh.y * COLS + neigh.x
			if not visited[idx] and current_cost + 1 < costs[idx]:
				costs[idx] = current_cost + 1
				queue.push_back(neigh)

	#queue_redraw() # <- important
	
func build_flow_field(player_cell : Vector2i):
	build_heat_map(player_cell, PAINT.BLACK)
	build_heat_map(player_cell, PAINT.YELLOW)
	build_flow_field_helper(player_cell, PAINT.BLACK)
	build_flow_field_helper(player_cell, PAINT.YELLOW)
	#print("yellow non-zero: ", flows_yellow.filter(func(f): return f != Vector2i.ZERO).size())
	#print("black non-zero: ", flows_black.filter(func(f): return f != Vector2i.ZERO).size())
	
func get_neighbors(node : Vector2i, paint : PAINT):
	var tile_color = paint_to_atlas_map[paint]
	var neighbors : Array[Vector2i] = []
	for dir in directions:
		var next = node + dir
		if next.x >= 0 and next.y >= 0 and next.x < COLS and next.y < ROWS:
			var neighbor_color = tiles.get_cell_atlas_coords(next)
			if tile_color == neighbor_color:
				neighbors.append(next)
	return neighbors
	
func build_flow_field_helper(player_cell : Vector2i, color : PAINT):
	
	var flows : Array[Vector2i] = flows_black if color == PAINT.BLACK else flows_yellow
	var costs : Array[float] = costs_black if color == PAINT.BLACK else costs_yellow
	flows.clear()
	flows.resize(ROWS * COLS)
	flows.fill(Vector2i.ZERO)
	
	for r in range(ROWS):
		for c in range(COLS):
			if costs[r * COLS + c] == INF: continue
			
			var best_cost = costs[r * COLS + c]
			var best_dir = Vector2i.ZERO
			
			for dir in directions:
				var neighbor_row = dir.y + r
				var neighbor_col = dir.x + c
				if neighbor_row >= 0 and neighbor_row < ROWS and neighbor_col >= 0 and neighbor_col < COLS:
					var neighbor_cost = costs[neighbor_row * COLS + neighbor_col]
					if neighbor_cost < best_cost:
						best_cost = neighbor_cost
						best_dir = dir
			
			flows[r * COLS + c] = best_dir
	
	#queue_redraw()
	
	
func _draw():
	#draw_heat_map()
	#draw_flow_field(flows_yellow, costs_yellow)
	pass
	

func draw_heat_map(costs : Array[float]):
	if costs.is_empty():
		return

	for y in range(ROWS):
		for x in range(COLS):

			var idx = y * COLS + x
			var value = costs[idx]

			if value == INF:
				continue
			var pos = Vector2(x * CELL_SIZE, y * CELL_SIZE)

			draw_string(
				font,
				pos + Vector2(2, CELL_SIZE - 2),
				str(int(value)),HORIZONTAL_ALIGNMENT_CENTER, -1, 8
			)


func draw_flow_field(flows : Array[Vector2i], costs : Array[float]):
	if flows.is_empty():
		#print("flows is empty!")
		return
	var non_zero = 0
	for f in flows:
		if f != Vector2i.ZERO:
			non_zero += 1
	#print("non-zero flows: ", non_zero, " / ", flows.size())
	
	for y in range(ROWS):
		for x in range(COLS):
			var idx = y * COLS + x
			if costs[idx] == INF:
				continue
			var dir = flows[idx]
			if dir == Vector2i.ZERO:
				continue
			var center = Vector2(x * CELL_SIZE + CELL_SIZE / 2.0, y * CELL_SIZE + CELL_SIZE / 2.0)
			var target = center + Vector2(dir) * (CELL_SIZE / 2.0 - 2)
			draw_line(center, target, Color.RED, 1.0)
			

	
