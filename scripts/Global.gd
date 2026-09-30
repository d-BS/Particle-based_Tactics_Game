extends Node


#Global variables here!!

var r_player_factions:Array[faction_data]
var r_player_faction_sizes:Array[int]

var time_scale:float = 1




var current_scene:Node = null
var game_root:Node

func _ready():
	game_root = get_tree().root
	current_scene = game_root.get_child(-1)
	
	
	setup_crt_shader()
	

func setup_crt_shader():
	
	add_global_node("res://scenes/visuals/pixel_subviewport.tscn")
	game_root.remove_child.call_deferred(current_scene)
	game_root = $PixelSubviewportContainer/SubViewport
	game_root.add_child.call_deferred(current_scene)
	game_root.gui_embed_subwindows = true
	
	add_global_node("res://scenes/visuals/crt_shader.tscn")
	$CrtShader/ColorRect.material.set_shader_parameter("curve_factor", Vector2(5, 5))
	

func add_global_node(path:String):
	
	var new_scene:PackedScene = ResourceLoader.load(path)
	add_child(new_scene.instantiate())

## changes the scene to the given path
func set_scene(path:String):
	current_scene.queue_free()
	_deferred_set_scene.call_deferred(path)


func _deferred_set_scene(path:String):

	var new_scene:PackedScene = ResourceLoader.load(path)
	
	current_scene = new_scene.instantiate()
	game_root.add_child(current_scene)
