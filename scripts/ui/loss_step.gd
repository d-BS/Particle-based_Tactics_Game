extends Node



func _on_button_3_pressed() -> void:
	
	get_tree().quit()
	
	pass # Replace with function body.



func _on_return_menu_pressed() -> void:
	
	Global.set_scene("res://scenes/ui/main_menu.tscn")
	
	pass # Replace with function body.



func _on_try_again_pressed() -> void:
	
	Global.set_scene("res://scenes/levels/start_run_step.tscn")
	
	pass # Replace with function body.
