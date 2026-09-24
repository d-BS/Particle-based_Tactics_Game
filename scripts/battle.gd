extends Node

#battle.gd

#This script is in charge of getting information from outer game loop,
#setting up the boid_manager using that information

#also in charge of communication between various sources during battle.
#For example, this script will call boid_manager's select_boids() func,
#this script will check for win condition, as well as things like relic
#activations and time scale.



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	
	#First gets information about current player state:
	#number and type of units, etc
	
	
	
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
