extends Node

#3072
#1920

#battle.gd

#This script is in charge of getting information from outer game loop,
#setting up the boid_manager using that information

#also in charge of communication between various sources during battle.
#For example, this script will call boid_manager's select_boids() func,
#this script will check for win condition, as well as things like relic
#activations and time scale.

@export var boid_manager:BoidManager

var starting_units:int

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	
	#First gets information about current player state:
	#number and type of units, etc
	
	#this is not how this will be stored later
	starting_units = Global.r_player_faction_sizes[0]
	
	
	#this is the sample faction
	var sample_faction:FactionData = Global.FACTIONS.load_entry("uid://dbxr6kni84usf")
	var enemy_faction:FactionData = Global.FACTIONS.load_entry("uid://caow6vbkisif0")#sample_faction.duplicate(true)
	sample_faction.num_units = starting_units
	enemy_faction.num_units = starting_units
	
	var fac_list:Array[FactionData] = [sample_faction, enemy_faction]
	
	
	Global.time_scale = 1
	
	
	#this logic should not be performed here
	var im_size = int(ceil(sqrt(2 * starting_units)))
	var start_zone:Rect2 = Rect2(0, 0, im_size * 25, im_size * 25)
	var enemy_zone:Rect2 = Rect2(im_size * 30, 0, im_size * 25, im_size * 25)
	
	fac_list[0].start_zone = start_zone
	fac_list[1].start_zone = enemy_zone
	
	RenderingServer.call_on_render_thread(boid_manager.setup.bind(fac_list))
	
	
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
func _physics_process(delta: float) -> void:
	
	
	if Global.time_scale == 0:
		
		return
	
	RenderingServer.call_on_render_thread(boid_manager.step_particle_sim.bind(delta))
	
	#excecute any queued actions
	RenderingServer.call_on_render_thread(boid_manager._update_squad_bias_uniform)
	RenderingServer.call_on_render_thread(boid_manager._update_boid_colors)
	
	
	
	
	pass
