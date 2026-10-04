extends CanvasLayer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass



func _on_continue_button_pressed() -> void:
	
	Global.pop_scene()
	
	pass # Replace with function body.



func _on_options_button_pressed() -> void:
	
	Global.pop_scene()
	Global.push_scene("res://scenes/ui/options_menu.tscn")
	
	pass # Replace with function body.



func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_pressed("esc"):
		Global.pop_scene()
		get_child(0).accept_event()
	


func _on_quit_button_pressed() -> void:
	Global.pop_scene()
	Global.set_scene("res://scenes/ui/main_menu.tscn")
	pass # Replace with function body.
