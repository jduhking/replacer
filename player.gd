class_name Player
extends CharacterBody2D

var paint : GameManager.PAINT = GameManager.PAINT.YELLOW


@export var movement_speed : float = 120
@export var acceleration : float = 0.6
@export var deceleration : float = 0.1
const MOVE_THRESHOLD : float = 1
var last_cell : Vector2i = Vector2i(-999, -999)

@onready var animator : AnimationPlayer = $AnimationPlayer

var elapsed_time : float = 0
var current_speed : float = 0
var was_moving : bool = false

func _physics_process(delta: float) -> void:

	var dir := Vector2(Input.get_axis("ui_left", "ui_right"), Input.get_axis("ui_up", "ui_down")).normalized()

	move(dir, delta)
	paint_floor()

func move(dir : Vector2, delta : float):
	var tilemap := GameManager.tiles
	var is_moving = dir.length() > 0

	elapsed_time += delta
	
	if is_moving:
		var t = clampf(elapsed_time / acceleration, 0,1)
		current_speed = lerpf(0, movement_speed, sin(t))
		animator.play("walk-" + ("black" if paint == GameManager.PAINT.BLACK	else "yellow"))
		var current_cell = tilemap.local_to_map(position)
		#print("current cell: ", current_cell, " last cell ", last_cell	)
		if current_cell.distance_to(last_cell) > MOVE_THRESHOLD:
			last_cell = current_cell
			GameManager.build_flow_field(current_cell)
	else:
		animator.play("idle-" + ("black" if paint == GameManager.PAINT.BLACK	else "yellow"))
		var t = clampf(elapsed_time / deceleration, 0,1)
		current_speed = lerpf(movement_speed, 0, sin(t))
	
		
	velocity = dir * current_speed
	move_and_slide()
	
	was_moving = is_moving
	
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

func current_tile():
	print("current tile: ", GameManager.tiles.local_to_map(position))
