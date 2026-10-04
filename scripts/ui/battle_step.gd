extends Node


func _on_win_con_pressed() -> void:
	
	Global.set_scene("res://scenes/levels/shop_step.tscn")
	
	pass # Replace with function body.



func _on_loss_con_pressed() -> void:
	
	Global.set_scene("res://scenes/levels/loss_step.tscn")
	
	pass # Replace with function body.
