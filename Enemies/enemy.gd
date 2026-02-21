class_name Enemy
extends CharacterBody2D

@export var paint : GameManager.PAINT = GameManager.PAINT.YELLOW

@export var max_movement_speed : float = 120
@export var min_movement_speed : float = 45
@export var movement_speed : float = 75
@export var acceleration : float = 0.6
@export var deceleration : float = 0.1

@onready var animator : AnimationPlayer = $AnimationPlayer

var elapsed_time : float = 0
var current_speed : float = 0
var was_moving : bool = false
var dir : Vector2

var target_cell : Vector2i = Vector2i.ZERO
var is_moving : bool = false

func _ready() -> void:
	await get_tree().process_frame
	var tilemap = GameManager.tiles
	target_cell = tilemap.local_to_map(position)
	var atlas = tilemap.get_cell_atlas_coords(target_cell)
	var valid = GameManager.paint_to_atlas_map[paint]
	movement_speed = randf_range(min_movement_speed, max_movement_speed)
	if atlas != valid:
		print("WARNING: ", name, " spawned on invalid tile ", atlas, " at ", target_cell)
	position = tilemap.map_to_local(target_cell)

func _physics_process(delta: float) -> void:
	var tilemap : TileMapLayer = GameManager.tiles
	var target_pos = tilemap.map_to_local(target_cell)
	
	
	if position.distance_to(target_pos) > 1.0:
		# move toward target cell center
		var dir = (target_pos - position).normalized()
		position += dir * movement_speed * delta
		animator.play("walk-" + ("black" if paint == GameManager.PAINT.BLACK else "yellow"))
	else:
		# snap to center and pick next cell from flow field
		position = target_pos
		animator.play("idle-" + ("black" if paint == GameManager.PAINT.BLACK else "yellow"))
		var current_flows = GameManager.flows_black if paint == GameManager.PAINT.BLACK else GameManager.flows_yellow
		if current_flows.size() > 0:
			var flow = current_flows[target_cell.y * GameManager.COLS + target_cell.x]
			if flow != Vector2i.ZERO:
				var next_cell = target_cell + flow
				if not GameManager.reserved_cells.has(next_cell):
					GameManager.reserved_cells.erase(target_cell)
					target_cell = next_cell
					GameManager.reserved_cells[target_cell] = true
	check_if_can_kill_player()
	check_if_on_invalid_tile()

func check_if_on_invalid_tile():
	var tilemap = GameManager.tiles
	var current_cell = tilemap.local_to_map(position)
	var atlas = tilemap.get_cell_atlas_coords(current_cell)
	if atlas != GameManager.paint_to_atlas_map[paint] and tilemap.local_to_map(GameManager.player.position) != current_cell:
		death()
		
func death():
	if GameManager.reserved_cells.has(target_cell):
		GameManager.reserved_cells.erase(target_cell)
	queue_free()
	
func check_if_can_kill_player():
	var tilemap = GameManager.tiles
	var current_cell = tilemap.local_to_map(position)
	if current_cell == tilemap.local_to_map(GameManager.player.position):
		GameManager.change_state(GameManager.GAMESTATE.GAMEOVER)

func paint_floor():
	var tilemap := GameManager.tiles
	if Input.is_action_just_pressed("toggle"):
		paint = GameManager.PAINT.YELLOW if paint == GameManager.PAINT.BLACK else GameManager.PAINT.BLACK
	var tilemap_position = tilemap.local_to_map(position)
	var tile_source_id := tilemap.get_cell_source_id(tilemap_position)
	
	if tile_source_id != -1:
		#print("atlas coord: ", tilemap.get_cell_atlas_coords(tilemap_position))
		#if tilemap.get_cell_atlas_coords(tilemap_position) in GameManager.VALID_FLOORS:
		tilemap.set_cell(tilemap_position, tile_source_id, GameManager.paint_to_atlas_map[paint] ,tilemap.get_cell_alternative_tile(tilemap_position))
#
#func print_current_cell():
	#print("current cell: ", GameManager.tiles.local_to_map(position), " atlas ", GameManager.tiles.get_cell_atlas_coords(GameManager.tiles.local_to_map(position)))
