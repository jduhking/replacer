extends Node

@onready var game_over_label : Label = $CanvasLayer/GameOverLabel
@onready var dark_mode_UI : TextureRect = $CanvasLayer/topBar/ColorRect/darkModeIndicator
@onready var light_mode_UI : TextureRect = $CanvasLayer/topBar/ColorRect/lightModeIndicator
@onready var score_label : Label = $CanvasLayer/topBar/ColorRect/ScoreNumber

var darkmode_texture_on : Texture2D = preload("res://UI/UI_res/tt-uidark-active.png")
var darkmode_texture_off : Texture2D = preload("res://UI/UI_res/tt-uidark-empty.png")
var lightmode_texture_on : Texture2D = preload("res://UI/UI_res/tt-uilight-active.png")
var lightmode_texture_off : Texture2D = preload("res://UI/UI_res/tt-uilight-empty.png")
#UI indicator images



func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func set_gameover_label(visible : bool):
	game_over_label.visible = visible

func set_mode_indicator (is_light_mode : bool): #true = light mode
	dark_mode_UI.texture = darkmode_texture_off if is_light_mode else darkmode_texture_on
	light_mode_UI.texture = lightmode_texture_on if is_light_mode else lightmode_texture_off

func update_score(time: float, score: float):
	var total = int(time / 60 + score)
	score_label.text = str(total).pad_zeros(6)
	
	
