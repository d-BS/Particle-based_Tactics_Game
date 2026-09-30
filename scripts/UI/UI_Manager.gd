extends CanvasLayer

@export var selection_box:Node2D
@export var boid_manager:BoidManager
@export var squad_list:ItemList

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	boid_manager.squads_updated.connect(_on_squads_updated)
	pass # Replace with function body.



func _on_play_button_pressed() -> void:
	
	Global.time_scale = 1
	
	pass # Replace with function body.


func _on_ff_button_pressed() -> void:
	
	if Global.time_scale < 16:
		Global.time_scale *= 2
	
	pass # Replace with function body.


func _on_pause_button_pressed() -> void:
	
	Global.time_scale = 0
	
	pass # Replace with function body.



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	
	for s in boid_manager.squads.size():
		
		squad_list.set_item_text(s*2+1, str("Squad ", s + 1, ", ", boid_manager.squads[s].units.size(), " units"))
		
	
	pass



func _on_squads_updated() -> void:
	
	for i in squad_list.item_count:
		squad_list.remove_item(0)
	
	var iterator:int = 0
	
	for s in boid_manager.squads:
		
		squad_list.add_item("<", null, false)
		
		
		squad_list.add_item(str("Squad ", iterator + 1, ", ", s.units.size(), " units"))
		
		
		iterator += 1
		
		pass
	
	if(boid_manager.selection_squad == -1):
		squad_list.deselect_all()
	else:
		squad_list.select(boid_manager.selection_squad)
	
	pass # Replace with function body.


func _on_option_button_item_selected(index: int) -> void:
	selection_box.mode = index
	pass # Replace with function body.


func _on_squad_list_item_selected(index: int) -> void:
	
	if index % 2 == 1:
		boid_manager.select_squad((index-1)/ 2)
	
	pass # Replace with function body.
