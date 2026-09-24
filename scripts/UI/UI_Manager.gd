extends CanvasLayer

@export var selection_box:Node2D
@export var boid_manager:BoidManager

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	$HBoxContainer/OptionButton.selection_box = selection_box
	$FoldableContainer/SquadList.boid_manager = boid_manager
	boid_manager.squads_updated.connect($FoldableContainer/SquadList._on_squads_updated)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	
	
	pass


func _on_play_button_pressed() -> void:
	
	Global.time_scale = 1
	
	pass # Replace with function body.


func _on_ff_button_pressed() -> void:
	
	
	Global.time_scale *= 2
	
	pass # Replace with function body.


func _on_pause_button_pressed() -> void:
	
	Global.time_scale = 0
	
	pass # Replace with function body.
