class_name RangedEnemy
extends Enemy

var shoot_direction : Vector2
const min_shoot_speed : float = 45
const max_shoot_speed : float = 200

@export var offset : float = 5

var fireball := preload("res://Enemies/fireball.tscn")

enum STATE { WALK, SHOOT, PAUSE }
var current_state : STATE = STATE.WALK
const min_follow_time : float = 0.2
const max_follow_time : float = 2.5

var follow_time : float = 0

@export var min_min_distance : int = 7
@export var max_min_distance : int = 15
@export var shoot_pause : float = 0.5

var shoot_elapsed_time : float = 0

func _ready() -> void:
	super()
	change_state(STATE.WALK)
	
func aim_player():
	shoot_direction = position.direction_to(GameManager.player.position)

func change_state(new_state : STATE):
	elapsed_time = 0
	shoot_elapsed_time = 0
	current_state = new_state
	match new_state:
		STATE.WALK:
			follow_time = randf_range(min_follow_time, max_follow_time)
			#print("shoot distance: ", shoot_distance)
		STATE.SHOOT:
			pass
		STATE.PAUSE:
			await get_tree().create_timer(shoot_pause).timeout		
			change_state(STATE.WALK)
	
func update_state(delta):
	match current_state:
		STATE.WALK:
			move(delta)
			elapsed_time += delta
			if elapsed_time >= follow_time:
				change_state(STATE.SHOOT)
		STATE.SHOOT:
			shoot_elapsed_time += delta
			if shoot_elapsed_time >= shoot_pause:
				shoot()
				change_state(STATE.PAUSE)
				
			
func _physics_process(delta: float) -> void:
	if GameManager.game_state == GameManager.GAMESTATE.GAMEOVER:
		return
	aim_player()
	update_state(delta)
 
	
func shoot():
	var current_tile = GameManager.tiles.local_to_map(position)
	var speed = randf_range(min_shoot_speed, max_shoot_speed)
	var game = get_parent()
	var fb : Fireball = fireball.instantiate()
	var spawn_point = position + shoot_direction * offset
	fb.position = spawn_point
	game.add_child(fb)
	fb.init(Vector2(shoot_direction).normalized(), speed)
	
