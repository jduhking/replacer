class_name Player
extends CharacterBody2D

var paint : GameManager.PAINT = GameManager.PAINT.YELLOW


@export var movement_speed : float = 120
@export var acceleration : float = 0.6
@export var deceleration : float = 0.1
@export var circle_threshold : float = 1
@export var min_circle_length : float = 4
const MOVE_THRESHOLD : float = 1
var last_cell : Vector2i = Vector2i(-999, -999)

var current_path = []
@onready var animator : AnimationPlayer = $AnimationPlayer

var elapsed_time : float = 0
var current_speed : float = 0
var was_moving : bool = false

signal painted(cell : Vector2i)

func _ready() -> void:
	GameManager.player = self
	painted.connect(_on_paint)
	GameManager.game_ended.connect(_on_game_over)
	
func _on_game_over():
	pass
	
func _on_paint(cell : Vector2i):
	GameManager.painted_cells[cell] = true

func _physics_process(delta: float) -> void:
	if GameManager.game_state == GameManager.GAMESTATE.GAMEOVER:
		return

	var dir := Vector2(Input.get_axis("ui_left", "ui_right"), Input.get_axis("ui_up", "ui_down")).normalized()

	move(dir, delta)
	paint_floor()

func move(dir : Vector2, delta : float):
	var is_moving = dir.length() > 0

	elapsed_time += delta
	
	if is_moving:
		var t = clampf(elapsed_time / acceleration, 0,1)
		current_speed = lerpf(0, movement_speed, sin(t))
		animator.play("walk-" + ("black" if paint == GameManager.PAINT.BLACK	else "yellow"))
		var current_cell = GameManager.tiles.local_to_map(position)
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
	
func switch_paint():	
	paint = GameManager.PAINT.YELLOW if paint == GameManager.PAINT.BLACK else GameManager.PAINT.BLACK
	UIManager.set_mode_indicator(paint == GameManager.PAINT.YELLOW)
	current_path.clear()

func paint_floor():
	if Input.is_action_just_pressed("toggle"):
		switch_paint()
	
	var tile_position = GameManager.tiles.local_to_map(position)
	var tile_source_id = GameManager.tiles.get_cell_source_id(tile_position)
	
	if tile_source_id != -1:
		GameManager.tiles.set_cell(tile_position, tile_source_id, GameManager.paint_to_atlas_map[paint], GameManager.tiles.get_cell_alternative_tile(tile_position))
		painted.emit(tile_position)
		
		if tile_position not in current_path:
			current_path.append(tile_position)
		
		if current_path.size() > min_circle_length:
			var start_cell = current_path[0]
			var is_closed = Vector2(tile_position).distance_to(Vector2(start_cell)) <= 2.0
			
			if is_closed:
				var centroid = get_centroid()
				var distances = []
				for cell in current_path:
					distances.append(Vector2(cell).distance_to(centroid))
				
				var mean = distances.reduce(func(a, b): return a + b) / distances.size()
				var variance = 0.0
				for d in distances:
					variance += (d - mean) * (d - mean)
				variance /= distances.size()
				var std_dev = sqrt(variance)
				
				if std_dev < circle_threshold:
					var min_x = current_path.map(func(c): return c.x).min()
					var max_x = current_path.map(func(c): return c.x).max()
					var min_y = current_path.map(func(c): return c.y).min()
					var max_y = current_path.map(func(c): return c.y).max()
					for y in range(min_y, max_y + 1):
						for x in range(min_x, max_x + 1):
							var cell = Vector2i(x, y)
							if Vector2(cell).distance_to(centroid) < mean:
								var source_id = GameManager.tiles.get_cell_source_id(cell)
								if source_id != -1:
									GameManager.tiles.set_cell(cell, source_id, GameManager.paint_to_atlas_map[paint], 0)
				
				current_path.clear()

		
func current_tile():
	print("current tile: ", GameManager.tiles.local_to_map(position))

func get_centroid() -> Vector2:
	if current_path.is_empty():
		return Vector2.ZERO
	var sum = Vector2.ZERO
	for cell in current_path:
		sum += Vector2(cell)
	return sum / current_path.size()
