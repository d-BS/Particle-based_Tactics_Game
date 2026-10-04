extends CanvasLayer

@export var crtCurveSlider: HSlider

@export var vignette_opac: HSlider
@export var vignette_r: HSlider
@export var vignette_g: HSlider
@export var vignette_b: HSlider

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass



func _on_pixel_amt_item_selected(index: int) -> void:
	
	Global.set_pixelation(index + 1)
	
	pass # Replace with function body.



func _on_crt_curve_value_changed(value: float) -> void:
	
	Global.set_crt_parameter("curve_factor", Vector2(value, value))
	
	pass # Replace with function body.

func _on_curve_check_button_toggled(toggled_on: bool) -> void:
	
	Global.set_crt_parameter("show_curvature", toggled_on)
	
	crtCurveSlider.editable = toggled_on
	
	pass # Replace with function body.


func _on_vignette_slider_value_changed(value: float) -> void:
	
	Global.set_crt_parameter("vignette_opacity", value)
	
	pass # Replace with function body.

func _on_vignette_r_value_changed(value: float) -> void:
	
	Global.set_crt_parameter("vignette_color", Vector3(value, vignette_g.value, vignette_b.value))
	
	pass # Replace with function body.

func _on_vignette_g_value_changed(value: float) -> void:
	Global.set_crt_parameter("vignette_color", Vector3(vignette_r.value, value, vignette_b.value))
	
	pass # Replace with function body.

func _on_vignette_b_value_changed(value: float) -> void:
	
	Global.set_crt_parameter("vignette_color", Vector3(vignette_r.value, vignette_g.value, value))
	
	pass # Replace with function body.

func _on_vignette_check_button_toggled(toggled_on: bool) -> void:
	
	vignette_opac.editable = toggled_on
	vignette_r.editable = toggled_on
	vignette_g.editable = toggled_on
	vignette_b.editable = toggled_on
	
	Global.set_crt_parameter("show_vignette", toggled_on)
	
	pass


func _on_scan_line_slider_value_changed(value: float) -> void:
	
	Global.set_crt_parameter("horizontal_scan_lines_opacity", value)
	
	pass # Replace with function body.

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("esc"):
		Global.pop_scene()
		get_child(0).accept_event()
