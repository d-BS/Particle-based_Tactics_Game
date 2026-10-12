#[compute]
#version 450
#extension GL_EXT_shader_atomic_float : enable
#define PI 3.14159265359

//to add:
//sleeping ... ?
//switch all instances of 'distance' and 'length'
// to dist^2 & len^2


//flat 128 threads.
//1024 from the tutorial didn't work for me, so I settled on this.

layout(local_size_x = 128, local_size_y = 1, local_size_z = 1) in;

layout(push_constant) uniform PushConstants {
	int pass_num;
	int num_boids;
	int image_size;
	float delta_time;

	//make this just a hash later
	float bin_h;
	float bin_w;
	float bin_offset_x;
	float bin_offset_y;
	
} rc;


//image out
layout(set = 0, rgba32f, binding = 0) restrict writeonly uniform image2D boid_data;


//buffer for the position of each boid
layout(set = 0, binding = 1, std430) restrict readonly buffer PosVel {
	vec4 data[];
} boid_posvel;



//buffer for bias provided by squad
layout(set = 0, binding = 2, std430) restrict readonly buffer SquadBias{
	vec2 data[];
} squad_bias;

//holds first / length
layout(set = 0, binding = 3, std430) restrict buffer BinMatrix{
	int data[];
} bin_mat;

layout(set = 0, binding = 4, std430) restrict buffer BinNext{
	int data[];
} bin_next;

struct Parameters {

    float vision_rad;
    float avoid_rad;


    float alignment_factor;
    float cohesion_factor;


    float damp_factor;

	float weight;
	float coeff_restitution;
	float friendly_fire;


	//air, fire, earth, metal, water, nature

};

//parameter buffer
layout(set = 0, binding = 5, std430) restrict readonly buffer Params{

	Parameters params[];
} ;

//sleeping?
//float sleep_cutoff;
//float wake_cutoff;


//holds health of each unit
layout(set = 0, binding = 6, std430) restrict buffer Health{
	float data[];
} health;

//holds faction # of each unit
layout(set = 0, binding = 7, std430) restrict buffer Faction{
	int data[];
} faction;

layout(set = 0, binding = 8, std430) restrict buffer ReturnAmt{
	int data[];
} return_amt;

layout(set = 0, binding = 9, std430) restrict buffer BoidReturn{
	int data[];
} boid_return;

//function prototypes
void binning_pass();
void boid_physics_pass();
void selection_pass();
void loop_over_bin(int);
void boid_loop_interior(int);
int get_bindex();
void storeImage();
float unpackFloat(int);


//locations for pass loc checks
//len of 2 for now, maybe this will change
shared vec2 loc_check[2];


//unique identifier for this instance
int index = int(gl_GlobalInvocationID.x);

//these variables are more convenient to have here
int num_neighbors = 0;

int avoid_neighbors = 0;
vec2 avoid_velocity_ave = vec2(0,0);

vec2 average_velocity = vec2(0,0);
vec2 average_position = vec2(0,0);

uint own_faction;
vec2 position;
vec2 velocity;


void main() {

	vec4 pos_vel = boid_posvel.data[index];
	own_faction = faction.data[index];

	position = pos_vel.rg;
	velocity = pos_vel.ba;

	
	//having this just makes some things cleaner
	if (index >= rc.num_boids){
		return;
	}
	if (health.data[index] <= 0){
		
		storeImage();
		return;
	}

	//anything that returns nothing can always go first
	//only allowed to run single one that does both, goes in middle
	//ones that do both need to have info passed from rear
	//anything that is passed nothing can always go last

	//binning, impulse, selection, physics



	switch(rc.pass_num){
		
		case 0:
			//nothing passed, nothing returned
			binning_pass();
			break;
		case 1:
			//passed impulse point(s) and strength(s) (damage?)
			//does not return
			//impulse_pass();
		case 2:
			//passed rectangle <- passed at VERY END
			//returns selected boids
			selection_pass();
			break;
		case 3:
			//not yet determined
			break;
		case 4:
			//nothing passed
			//returns dead boids
			boid_physics_pass();
			break;

	}


	//if (params.pass_number == 0.0)
	//	binning_pass();
	//else if(params.pass_number == 1.0)
	//	boid_physics_pass();

		

	
}

void boid_physics_pass() {



	//last resort catches
	//dont like that I need this
	//if (isnan(position.x) || isnan(position.y) || isinf(position.x) || isinf(position.y))
	//	position = vec2(0, 0);
	//if (isnan(velocity.x) || isnan(velocity.y) || isinf(velocity.x) || isinf(velocity.y))
	//	velocity = vec2(0, 0);




	

	//bool kicker = velocity.length() >= wakeup cutoff


	

	int bindex = get_bindex();
	int[9] neighborhood = {-1, 0, 1, int(-rc.bin_w - 1), int(-rc.bin_w), int(-rc.bin_w + 1), int(rc.bin_w - 1), int(rc.bin_w), int(rc.bin_w + 1)};

	for(int i = 0; i < 9; i++){

		loop_over_bin(neighborhood[i] + bindex);
	}

	if (num_neighbors > 0 ){

		//this causes groups to go faster whn alignment_factor is positive
		velocity += (average_velocity / num_neighbors) * params[own_faction].alignment_factor * rc.delta_time;

		//applies average position
		velocity += (average_position / num_neighbors - position) * params[own_faction].cohesion_factor * rc.delta_time;
	}

	if(avoid_neighbors != 0){

		velocity = avoid_velocity_ave / avoid_neighbors;
	}




	vec2 personal_squad_bias = squad_bias.data[index];
	if(!isinf(personal_squad_bias[0])){
		
		vec2 bias = personal_squad_bias - position;
		float bias_cutoff_squared = 36; //so 6 normally

		//ridiculous degrees of magic numbers
		if(bias != vec2(0,0) && (bias.x*bias.x + bias.y*bias.y) > bias_cutoff_squared)
			velocity += normalize(bias) * rc.delta_time * 50;

	}

	//applies damping
	velocity /= 1 + params[own_faction].damp_factor * rc.delta_time;


	//if velocity < sleep cutoff and avg_vel < sleep cutoff
	//sleep


	
	position += velocity * rc.delta_time;

	storeImage();
}

// apply damage to unit i
// this will be a real calculation later, for now its simpler
void damage_calculation(uint i){

	float friendly_fire = 1;
	float damage = -10;

	//damage calculation will go here
	if(faction.data[index] + faction.data[i] % 2 == 0)
		friendly_fire = params[own_faction].friendly_fire;
	
	damage *= rc.delta_time * friendly_fire;
	
	float former_health = atomicAdd(health.data[i], damage);

	if(-damage >= former_health){
		//add to toDelete
	}

}



void boid_loop_interior(int i){

	if(i==index){ return;}

	vec4 other_posvel = boid_posvel.data[i];

	float distance = distance(position, other_posvel.rg);

	if(distance < params[own_faction].vision_rad){


		num_neighbors++;
		average_velocity += other_posvel.ba;
		average_position += other_posvel.rg;

		if(distance < params[own_faction].avoid_rad){
			

			
						
			float own_weight = params[own_faction].weight;
			float other_weight = params[faction.data[i]].weight;

			//coefficient of restitution - We potentially need other as well
			float e = params[own_faction].coeff_restitution;

			
			//direction away from colliding unit
			vec2 normal = position - other_posvel.rg;
			float len = length(normal);

			//if overlapping, applies pseudorandom impulse
			if (len == 0){
				damage_calculation(i);
				position += vec2(sin(index), cos(index));
				return;
			}
			normal /= len;

			//unstuck / sliding
			if (len < params[own_faction].avoid_rad){
				
				//I think this is how this should include weight, but I'm not sure
				avoid_velocity_ave += normal * (params[own_faction].avoid_rad - len) * 5 * (2*other_weight/(other_weight+own_weight));

				//position += normal * (params.avoid_rad * 1.01 - len) * params.delta_time * 5;
				//position += normal * params.delta_time * 5;
			}
			
			// how fast we're going in the direction parallel to the direction toward the other unit
			// (velocity perpendicular is unchanged by collision)
			float own_vel_normal = dot(velocity, normal);
			float other_vel_normal = dot(other_posvel.ba, normal);

			
			avoid_neighbors++;

			//if already moving away from each other
			if (own_vel_normal - other_vel_normal > 0.0){
				avoid_velocity_ave += velocity;
				damage_calculation(i);
				return;
			
			}
			
			//collision formula
			float own_vel_normal_final = (own_weight * own_vel_normal
									+ other_weight * other_vel_normal
									+ other_weight * e * (other_vel_normal - own_vel_normal))
									/ (own_weight + other_weight);
			
			avoid_velocity_ave += velocity + (own_vel_normal_final - own_vel_normal) * normal;
			

			damage_calculation(i);
		}
	}
}


void loop_over_bin(int bindex){

	if(bindex < 0 || bindex >= rc.bin_h * rc.bin_w)
		return;

	int to_check = bin_mat.data[bindex];

	while(to_check != -1){

		//kinda wish I had a better solution than this
		if (to_check >= rc.num_boids || health.data[to_check] <=0) {
        	to_check = bin_next.data[to_check];
        	continue;
    	}

		boid_loop_interior(to_check);
		to_check = bin_next.data[to_check];
	}
}








void binning_pass() {

	
	//first, find location relative to bins
	//find bin
	//add to bin

	

	int bindex = get_bindex();

	if(bindex == -1)
		return;

	if (index < rc.num_boids || health.data[index] > 0) {

		int old_head = atomicExchange(bin_mat.data[bindex], index);
		bin_next.data[index] = old_head;
	}
	return;

}



int get_bindex(){


	vec2 bin_pos = (position - vec2(rc.bin_offset_x, rc.bin_offset_y)) / params[own_faction].vision_rad;


	int bx = int(floor(bin_pos.x));
    int by = int(floor(bin_pos.y));

	if (bx < 0 || bx >= rc.bin_w) return -1;
    if (by < 0 || by >= rc.bin_h) return -1;

	return int(bx + (by * rc.bin_w));

}

void storeImage(){


	int img_size_int = int(rc.image_size);
	ivec2 pixel_pos = ivec2(index % img_size_int, index / img_size_int);
	
	imageStore(boid_data, pixel_pos, vec4(position.x, position.y, velocity.x, velocity.y));
}

//unpacks a floating point number from integer in input array
float unpackFloat(int index){

	return intBitsToFloat(boid_return.data[index]);
}

//pass id 2
//this is passed info, and returns info
//it wil always be the only one that does both
//it will always be the first pass to return data
//info is passed from rear of input buffer
void selection_pass(){

	if(gl_LocalInvocationIndex == 0){

		
		int passed_rect = int(pow(rc.image_size, 2));

		//uses 4 total int slots

		loc_check[0] = vec2(unpackFloat(passed_rect - 4), unpackFloat(passed_rect - 3));
		loc_check[1] = vec2(unpackFloat(passed_rect - 2), unpackFloat(passed_rect - 1));
	}

	barrier();
	memoryBarrierShared();

	//check if pos is inside rect:

	//if pos is greater than position,
	//but also less than end

	vec2 rect_pos = loc_check[0];
	vec2 rect_end = loc_check[1];
	
	if(position.x > rect_pos.x && position.y > rect_pos.y && position.x < rect_end.x && position.y < rect_end.y && faction.data[index] % 2 == 0){

		//increment return size, return own index
		boid_return.data[atomicAdd(return_amt.data[2], 1)] = index;

	}
}