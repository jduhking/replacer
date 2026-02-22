class_name EliteEnemy
extends Enemy

signal painted(cell : Vector2i)

func _physics_process(delta: float) -> void:
	move(delta)
	
func _ready():
	super()
	painted.connect(_on_paint)
	
func _on_paint(cell : Vector2i):
	GameManager.painted_cells[cell] = true
	

func move(delta : float):
	var target = GameManager.tiles.map_to_local(target_cell)
	
	if position.distance_to(target) > 1.0:
		# move toward target cell center
		var dir = (target - position).normalized() if (target - position).normalized() != Vector2.ZERO else dir
		print("current dir: ", dir)
		position += dir * movement_speed * delta
		print("position ", position)
		animator.play("walk-" + ("black" if paint == GameManager.PAINT.BLACK else "yellow"))
	else:
		# snap to center and pick next cell from flow field
		position = target
		animator.play("idle-" + ("black" if paint == GameManager.PAINT.BLACK else "yellow"))
		var current_flows = GameManager.flows_black if paint == GameManager.PAINT.BLACK else GameManager.flows_yellow
		if current_flows.size() > 0:
			var flow = current_flows[target_cell.y * GameManager.COLS + target_cell.x]
			var player_cell = GameManager.tiles.local_to_map(GameManager.player.position)
			if flow != Vector2i.ZERO:
				var next_cell = target_cell + flow
				if next_cell == player_cell or (not GameManager.reserved_cells.has(next_cell)):
					GameManager.reserved_cells.erase(target_cell)
					target_cell = next_cell
					paint_floor(target_cell)
					GameManager.reserved_cells[target_cell] = true
	check_if_can_kill_player()
	check_if_on_invalid_tile()

func _on_body_entered(body : Node2D):
	if body.is_in_group("Player"):
		GameManager.change_state(GameManager.GAMESTATE.GAMEOVER)

	
func paint_floor(cell : Vector2i):
	var tile_position = cell
	var tile_source_id = GameManager.tiles.get_cell_source_id(tile_position)
	
	if tile_source_id != -1 and GameManager.tiles.get_cell_atlas_coords(cell) != GameManager.paint_to_atlas_map[paint]:
		GameManager.tiles.set_cell(tile_position, tile_source_id, GameManager.paint_to_atlas_map[paint], GameManager.tiles.get_cell_alternative_tile(tile_position))
		GameManager.build_flow_field(GameManager.tiles.local_to_map(GameManager.player.position))
		GameManager.painted_cells[cell] = true
