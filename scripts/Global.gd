extends Node


#Global variables here!!

var r_player_factions:Array[faction_data]
var r_player_faction_sizes:Array[int]

var time_scale:float = 1






var current_scene:Node = null

func _ready():
	var root = get_tree().root
	current_scene = root.get_child(-1)

## changes the scene to the given path
func set_scene(path:String):
	current_scene.queue_free()
	_deferred_set_scene.call_deferred(path)


func _deferred_set_scene(path:String):

	var new_scene:PackedScene = ResourceLoader.load(path)
	
	current_scene = new_scene.instantiate()
	
	
	get_tree().root.add_child(current_scene)
