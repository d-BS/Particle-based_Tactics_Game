extends Node


#Global variables here!!

var r_player_factions:Array[faction_data]
var r_player_faction_sizes:Array[int]

var time_scale:float = 1


var current_scene:Node = null
var scene_stack:Array[Node] = []
var game_root:Node

func _ready():
	game_root = get_tree().root
	current_scene = game_root.get_child(-1)
	
	
	setup_crt_shader()
	

func _unhandled_input(event: InputEvent) -> void:

	if event.is_action_pressed("esc"):
		push_scene("res://scenes/ui/pause_menu.tscn")
	
	pass


func add_global_node(path:String):
	
	var new_scene:PackedScene = ResourceLoader.load(path)
	add_child(new_scene.instantiate())


## changes the scene to the given path
func set_scene(path:String):
	current_scene.queue_free()
	_deferred_set_scene.call_deferred(path)

## adds scene on top of current scene
func push_scene(path:String):
	
	var new_scene:PackedScene = ResourceLoader.load(path)
	var new_stack:Node = new_scene.instantiate()
	game_root.add_child(new_stack)
	scene_stack.push_back(new_stack)
	
	pass

## removes topmost stacked scene
func pop_scene():
	
	scene_stack.pop_back().queue_free()
	
	pass

func _deferred_set_scene(path:String):

	var new_scene:PackedScene = ResourceLoader.load(path)
	
	current_scene = new_scene.instantiate()
	game_root.add_child(current_scene)


func setup_crt_shader():
	
	add_global_node("res://scenes/visuals/pixel_subviewport.tscn")
	game_root.remove_child.call_deferred(current_scene)
	game_root = $PixelRatio/PixelSubviewportContainer/SubViewport
	game_root.add_child.call_deferred(current_scene)
	game_root.gui_embed_subwindows = true
	
	add_global_node("res://scenes/visuals/crt_shader.tscn")
	$CrtShader/ColorRect.material.set_shader_parameter("curve_factor", Vector2(5, 5))
	

func set_crt_parameter(parameter:String, value):
	
	$CrtShader/ColorRect.material.set_shader_parameter(parameter, value)
	
func get_crt_parameter(parameter:String) -> Variant:
	
	return $CrtShader/ColorRect.material.get_shader_parameter(parameter)

func set_pixel_parameter(parameter:String, value):
	
	game_root.get_node("PixelFX/PixelShader").material.set_shader_parameter(parameter, value)

func get_pixel_parameter(parameter:String) -> Variant:
	
	return game_root.get_node("PixelFX/PixelShader").material.get_shader_parameter(parameter)


## will probably add more stuff to here later
func set_pixelation(pixel_factor:int):
	
	get_node("PixelRatio/PixelSubviewportContainer").stretch_shrink = pixel_factor
	set_crt_parameter("screen_size", get_window().content_scale_size / pixel_factor)
	
	
	
