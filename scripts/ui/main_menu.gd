extends Control

@export var num_selector:SpinBox

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	#RenderingServer.set_default_clear_color(Color.CADET_BLUE)
	
	pass




func _on_button_exit_pressed() -> void:
	
	get_tree().quit()
	
	pass # Replace with function body.




func _on_button_start_pressed() -> void:
	
	var num_units:int = num_selector.value
	Global.r_player_faction_sizes = [ceil(num_units/2), floor(num_units/2.0)]
	
	Global.set_scene("res://scenes/levels/battle.tscn")
	
	pass # Replace with function body.
