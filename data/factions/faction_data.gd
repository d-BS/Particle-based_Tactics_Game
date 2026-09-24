class_name faction_data
extends Resource

@export var faction_id:String
@export var display_name:String
@export_multiline var description:String
@export_category("Stats")
@export_range(1, 100, 1, "or_greater") var max_health:int = 1
@export_range(0.01, 100, 0.01, "or_greater") var weight:float = 1
@export_group("Alignment")
@export_range(1, 100, 1, "or_greater") var air_alignment:int = 1
@export_range(1, 100, 1, "or_greater") var fire_alignment:int = 1
@export_range(1, 100, 1, "or_greater") var earth_alignment:int = 1
@export_range(1, 100, 1, "or_greater") var metal_alignment:int = 1
@export_range(1, 100, 1, "or_greater") var water_alignment:int = 1
@export_range(1, 100, 1, "or_greater") var nature_alignment:int = 1
@export_category("Appearance")
@export_color_no_alpha var color:Color = Color.WHITE
@export_file var icon:String
@export_file var sprite:String
