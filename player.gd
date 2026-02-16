class_name Player
extends CharacterBody2D

enum PAINT { YELLOW, BLACK }
var paint_to_atlas_map = { PAINT.YELLOW : GameManager.YELLOW_TILE , PAINT.BLACK : GameManager.BLACK_TILE }
var paint : PAINT = PAINT.YELLOW


@export var movement_speed : float = 120
@export var acceleration : float = 0.6
@export var deceleration : float = 0.1

var elapsed_time : float = 0
var current_speed : float = 0
var was_moving : bool = false

func _physics_process(delta: float) -> void:

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var dir_x := Input.get_axis("ui_left", "ui_right")
	var dir_y := Input.get_axis("ui_up", "ui_down")
	
	var dir := Vector2(dir_x, dir_y).normalized()
	
	var is_moving = dir.length() > 0
	
	elapsed_time += delta
	
	if is_moving:
		var t = clampf(elapsed_time / acceleration, 0,1)
		current_speed = lerpf(0, movement_speed, sin(t))
	else:
		var t = clampf(elapsed_time / deceleration, 0,1)
		current_speed = lerpf(movement_speed, 0, sin(t))
		
	velocity = dir * current_speed
	move_and_slide()
	was_moving = is_moving
	var tilemap := GameManager.tiles
	if Input.is_action_just_pressed("toggle"):
		paint = PAINT.YELLOW if paint == PAINT.BLACK else PAINT.BLACK
	var tilemap_position = tilemap.local_to_map(position)
	var tile_source_id := tilemap.get_cell_source_id(tilemap_position)
	
	if tile_source_id != -1:
		#print("atlas coord: ", tilemap.get_cell_atlas_coords(tilemap_position))
		#if tilemap.get_cell_atlas_coords(tilemap_position) in GameManager.VALID_FLOORS:
		tilemap.set_cell(tilemap_position, tile_source_id, paint_to_atlas_map[paint] ,tilemap.get_cell_alternative_tile(tilemap_position))
