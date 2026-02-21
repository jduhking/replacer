extends Node

@onready var game_over_label : Label = $CanvasLayer/GameOverLabel
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func set_gameover_label(visible : bool):
	game_over_label.visible = visible
