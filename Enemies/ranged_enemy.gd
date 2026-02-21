class_name RangedEnemy
extends Enemy

var shoot_direction : Vector2i
const min_shoot_speed : float = 45
const max_shoot_speed : float = 200

var fireball := preload("res://Enemies/fireball.tscn")

enum STATE { WALK, SHOOT }
var current_state : STATE = STATE.WALK

@export var min_min_distance : int = 6
@export var max_min_distance : int = 15
var shoot_distance 
@export var shoot_pause : float = 0.5

var shoot_elapsed_time : float = 0

func _ready() -> void:
	super()
	change_state(STATE.WALK)
	
func aim_player():
	var current_tile = GameManager.tiles.local_to_map(position)
	var player_tile = GameManager.tiles.local_to_map(GameManager.player.position)
	var dir = player_tile - current_tile
	shoot_direction = Vector2i(sign(dir.x), sign(dir.y))

func change_state(new_state : STATE):
	elapsed_time = 0
	shoot_elapsed_time = 0
	current_state = new_state
	match new_state:
		STATE.WALK:
			shoot_distance = randi_range(min_min_distance, max_min_distance)
			#print("shoot distance: ", shoot_distance)
		STATE.SHOOT:
			pass

			
func update_state(delta):
	match current_state:
		STATE.WALK:
			move(delta)
			var current_cell = GameManager.tiles.local_to_map(position)
			var player_cell = GameManager.tiles.local_to_map(GameManager.player.position)
			var distance = player_cell.distance_to(current_cell)
			if distance >= shoot_distance:
				change_state(STATE.SHOOT)
		STATE.SHOOT:
			shoot_elapsed_time += delta
			if shoot_elapsed_time >= shoot_pause:
				shoot()
				await get_tree().create_timer(shoot_pause).timeout
				change_state(STATE.WALK)
			
func _physics_process(delta: float) -> void:
	aim_player()
	update_state(delta)
	
func move(delta : float):
	var target = GameManager.tiles.map_to_local(target_cell)
	if position.distance_to(target) > 1.0:
		# move toward target cell center
		var dir = (target - position).normalized()
		position += dir * movement_speed * delta
		animator.play("walk-" + ("black" if paint == GameManager.PAINT.BLACK else "yellow"))
	else:
		# snap to center and pick next cell from flow field
		position = target
		animator.play("idle-" + ("black" if paint == GameManager.PAINT.BLACK else "yellow"))
		var current_flows = GameManager.flows_black if paint == GameManager.PAINT.BLACK else GameManager.flows_yellow
		if current_flows.size() > 0:
			var flow = current_flows[target_cell.y * GameManager.COLS + target_cell.x]
			if flow != Vector2i.ZERO:
				var next_cell = target_cell + (-flow)
				var atlas = GameManager.tiles.get_cell_atlas_coords(next_cell)
				if atlas == GameManager.paint_to_atlas_map[paint] and not GameManager.reserved_cells.has(next_cell):
					GameManager.reserved_cells.erase(target_cell)
					target_cell = next_cell
					GameManager.reserved_cells[target_cell] = true
	check_if_can_kill_player()
	check_if_on_invalid_tile()
	
func shoot():
	var current_tile = GameManager.tiles.local_to_map(position)
	var speed = randf_range(min_shoot_speed, max_shoot_speed)
	var game = get_parent()
	var fb : Fireball = fireball.instantiate()
	var spawn_point = GameManager.tiles.map_to_local(current_tile + shoot_direction)
	fb.position = spawn_point
	game.add_child(fb)
	fb.init(Vector2(shoot_direction).normalized(), speed)
	
