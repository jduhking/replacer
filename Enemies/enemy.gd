class_name Enemy
extends CharacterBody2D

@export var paint : GameManager.PAINT = GameManager.PAINT.YELLOW

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
				target_cell = target_cell + flow

func move(dir : Vector2, delta : float):
	var tilemap := GameManager.tiles
	var is_moving = dir.length() > 0
	elapsed_time += delta

	if is_moving:
		var t = clampf(elapsed_time / acceleration, 0, 1)
		current_speed = lerpf(0, movement_speed, sin(t))
		animator.play("walk-" + ("black" if paint == GameManager.PAINT.BLACK else "yellow"))
	else:
		animator.play("idle-" + ("black" if paint == GameManager.PAINT.BLACK else "yellow"))
		var t = clampf(elapsed_time / deceleration, 0, 1)
		current_speed = lerpf(movement_speed, 0, sin(t))

	var current_tile = tilemap.local_to_map(position)
	var cell_center = tilemap.map_to_local(current_tile)
	var to_center = cell_center - position
	var perpendicular = Vector2(-dir.y, dir.x)
	var lateral = clamp(perpendicular.dot(to_center), -2.0, 2.0)
	velocity = dir.normalized() * current_speed + perpendicular * lateral if is_moving else Vector2.ZERO
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

func print_current_cell():
	print("current cell: ", GameManager.tiles.local_to_map(position), " atlas ", GameManager.tiles.get_cell_atlas_coords(GameManager.tiles.local_to_map(position)))
