extends Node

#battle.gd

#This script is in charge of getting information from outer game loop,
#setting up the boid_manager using that information

#also in charge of communication between various sources during battle.
#For example, this script will call boid_manager's select_boids() func,
#this script will check for win condition, as well as things like relic
#activations and time scale.

@export var boid_manager:BoidManager

var allied_starting_units:int
var enemy_starting_units:int

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	
	#First gets information about current player state:
	#number and type of units, etc
	
	allied_starting_units = Global.r_player_faction_sizes[0]
	enemy_starting_units = Global.r_player_faction_sizes[1]
	
	
	var im_size = int(ceil(sqrt(allied_starting_units + enemy_starting_units)))
	
	var start_zone:Rect2 = Rect2(0, 0, im_size * 25, im_size * 25)
	var enemy_zone:Rect2 = Rect2(im_size * 30, 0, im_size * 25, im_size * 25)
	
	boid_manager.setup(start_zone, allied_starting_units, enemy_zone, enemy_starting_units)
	
	
	pass # Replace with function body.

func _unhandled_input(event: InputEvent) -> void:
	
	if event.is_action_pressed("F"):
		
		if boid_manager.selection_squad != -1:
			boid_manager.squads[boid_manager.selection_squad].set_formation("rect")
			
			
		pass
	
	if event.is_action_pressed("rclick"):
		
		$Flag.position = $Flag.get_global_mouse_position()
		boid_manager.set_selected_bias($Flag.position)
		
	
	#clears bias
	if event.is_action_pressed("delete"):
		boid_manager.set_selected_bias(Vector2.INF)
	
	if event.is_action_pressed("space"):
		
		Global.set_scene("res://scenes/ui/main_menu.tscn")
		
	
	pass
	
	pass




# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	
	
	
	
	
	pass
