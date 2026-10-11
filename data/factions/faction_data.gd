class_name FactionData
extends Resource

## number of units in this faction
var num_units:int
## where this faction starts
var start_zone:Rect2

@export var faction_id:String
enum RARITY {average, unusual, extraordinary, prodigal, divine}
@export var rarity:RARITY


@export var display_name:String
@export_multiline var description:String
@export_category("Stats")

const vision_rad:float = 35
const avoid_rad:float = 25

## This is how much units try to go in a similar direction. Also 
## indirectly causes groups to go faster/slower than individuals.
@export var alignment_factor:float = -.7

## This is how much each unit tries to move toward local
## average position. A positive value will make them clump up,
## while a negative value will cause them to have personal space.
@export var cohesion_factor:float = -.05

## Unit velocity is divided by this amount + 1 every second.
## a value close to 0 WILL cause explosion. make sure this and
## weight match!
@export var damp_factor:float = 1.4

## How heavy the unit is - important in damage and
## collision calculations - make sure this and damping match!
## Really want heavy units to be slow and really 'feel' heavy
@export_range(0.01, 100, 0.01, "or_greater") var weight:float = 1

## This is how 'bouncy' the unit is.
## When colliding, if both units have coeff of 0, they will stick together.
## If both units have coeff of 1, they have perfect elastic collision
@export_range(0, 1, 0.01) var coeff_restitution:float = .5

## Damage to allies is multiplied by this amount (usually more than zero & at most one, but not always)
@export_range(0, 1, 0.01, "or_greater") var friendly_fire:float = .1

## max health
@export_range(1, 100, 1, "or_greater") var max_health:int = 100


@export_group("Elemental Alignment")
@export_range(1, 100, 1, "or_greater") var air_algn:float = 1
@export_range(1, 100, 1, "or_greater") var fire_algn:float = 1
@export_range(1, 100, 1, "or_greater") var earth_algn:float = 1
@export_range(1, 100, 1, "or_greater") var metal_algn:float = 1
@export_range(1, 100, 1, "or_greater") var water_algn:float = 1
@export_range(1, 100, 1, "or_greater") var nature_algn:float = 1



@export_category("Appearance")
@export_color_no_alpha var color:Color = Color.WHITE
@export_file var icon:String
@export_file var sprite:String

## gets the faction parameters as used in compute shader, with current order being:
## vision_rad, avoid_rad, alignment_factor, cohesion_factor, damp_factor, weight, coeff_restitution, friendly_fire
func get_params() -> PackedFloat32Array:
	#add alignments
	
	return PackedFloat32Array([vision_rad, avoid_rad, alignment_factor, cohesion_factor, damp_factor, weight, coeff_restitution, friendly_fire])

## returns the attk stat (pricy, uses sqrt)
func get_power():
	
	return sqrt((air_algn * air_algn) + (fire_algn * fire_algn) + (earth_algn * earth_algn) + (metal_algn * metal_algn) + (water_algn * water_algn) + (nature_algn * nature_algn))
	

## updates elemental alignments to set power to specific value
## (uses sqrt)
func set_power(new_power:float):
	
	var magnitude:float = get_power()
	
	air_algn = new_power * air_algn / magnitude
	fire_algn = new_power * fire_algn / magnitude
	earth_algn = new_power * earth_algn / magnitude
	metal_algn = new_power * metal_algn / magnitude
	water_algn = new_power * water_algn / magnitude
	nature_algn = new_power * nature_algn / magnitude
	
