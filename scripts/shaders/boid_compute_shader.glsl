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
	float delta_time;
} rc;


//image out
layout(set = 0, rgba32f, binding = 0) restrict writeonly uniform image2D boid_data;


//buffer for the position of each boid
layout(set = 0, binding = 1, std430) restrict readonly buffer PosVel {
	vec4 data[];
} boid_posvel;



//buffer for bias provided by squad
layout(set = 0, binding = 2, std430) restrict buffer SquadBias{
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
	float num_boids;
    float image_size;
    float vision_rad;
    float avoid_rad;

	float bin_h;
	float bin_w;

	float bin_offset_x;
	float bin_offset_y;


    float alignment_factor;
    float cohesion_factor;
    float avoidance_factor;
    float damp_factor;

	//currently unused - change to weight and coefficient of restitution
	float pass_number;
    float delta_time;
};

//parameter buffer
layout(set = 0, binding = 5, std430) restrict buffer Params{

	Parameters params;
} ;


//Faction-based parameters:

//layout(set = 0, binding = 5, std430) restrict buffer Params{
//	Parameters params[];
//} ;




//weight
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

//layout(set = 0, binding = 8, std430) restrict buffer ToDelete{
//	int data[];
//} to_delete;


//function prototypes
void binning_pass();
void boid_physics_pass();
void loop_over_bin(int);
void boid_loop_interior(int);
int get_bindex();
void storeImage();



//unique identifier for this instance
int index = int(gl_GlobalInvocationID.x);


//these variables are more convenient to have here
int num_neighbors = 0;

int avoid_neighbors = 0;
vec2 avoid_velocity_ave = vec2(0,0);

vec2 average_velocity = vec2(0,0);
vec2 average_position = vec2(0,0);

vec2 position;
vec2 velocity;


void main() {

	vec4 pos_vel = boid_posvel.data[index];

	position = pos_vel.rg;
	velocity = pos_vel.ba;

	
	//having this just makes some things cleaner
	if (index >= params.num_boids){
		return;
	}
	if (health.data[index] <= 0){
		
		storeImage();
		return;
	}


	switch(rc.pass_num){

		case 0:
			binning_pass();
			break;
		case 1:
			boid_physics_pass();
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
	int[9] neighborhood = {-1, 0, 1, int(-params.bin_w - 1), int(-params.bin_w), int(-params.bin_w + 1), int(params.bin_w - 1), int(params.bin_w), int(params.bin_w + 1)};

	for(int i = 0; i < 9; i++){

		loop_over_bin(neighborhood[i] + bindex);
	}

	if (num_neighbors > 0 ){

		//this causes groups to go faster whn alignment_factor is positive
		velocity += (average_velocity / num_neighbors) * params.alignment_factor * rc.delta_time;

		//applies average position
		velocity += (average_position / num_neighbors - position) * params.cohesion_factor * rc.delta_time;
	}

	if(avoid_neighbors != 0){

		velocity = avoid_velocity_ave / avoid_neighbors;
	}




	//Formerly
		//velocity += squad_bias * delta * bias_factor
		//magic number .075 for bias_factor
		//velocity += squad_bias.data[index] * params.delta_time * .075;
	

	vec2 personal_squad_bias = squad_bias.data[index];
	if(!isinf(personal_squad_bias[0])){
		
		vec2 bias = personal_squad_bias - position;
		float bias_cutoff_squared = 36; //so 6 normally

		//ridiculous degrees of magic numbers
		if(bias != vec2(0,0) && (bias.x*bias.x + bias.y*bias.y) > bias_cutoff_squared)
			velocity += normalize(bias) * rc.delta_time * 50;

	}

	//applies damping
	velocity /= 1 + params.damp_factor * rc.delta_time;


	//if velocity < sleep cutoff and avg_vel < sleep cutoff
	//sleep


	
	position += velocity * rc.delta_time;

	storeImage();
}


void damage_calculation(uint i){

	//damage calculation will go here
	if(faction.data[index] % 2 != faction.data[i] % 2)
		atomicAdd(health.data[i], -10 * rc.delta_time);
	else
		atomicAdd(health.data[i], -1 * rc.delta_time);
}



void boid_loop_interior(int i){

	if(i==index){ return;}

	vec4 other_posvel = boid_posvel.data[i];

	float distance = distance(position, other_posvel.rg);

	if(distance < params.vision_rad){


		num_neighbors++;
		average_velocity += other_posvel.ba;
		average_position += other_posvel.rg;

		if(distance < params.avoid_rad){
			

			
						
			float own_weight = 1.0;
			float other_weight = 1.0;
			//coefficient of restitution
			float e = .5;

			

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
			if (len < params.avoid_rad){
				
				//I think this is how this should include weight, but I'm not sure
				avoid_velocity_ave += normal * (params.avoid_rad - len) * 5 * (2*other_weight/(other_weight+own_weight));

				//position += normal * (params.avoid_rad * 1.01 - len) * params.delta_time * 5;
				//position += normal * params.delta_time * 5;
			}
			

			float own_vel_normal = dot(velocity, normal);
			float other_vel_normal = dot(other_posvel.ba, normal);

			
			avoid_neighbors++;

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

	if(bindex < 0 || bindex >= params.bin_h * params.bin_w)
		return;

	int to_check = bin_mat.data[bindex];

	while(to_check != -1){

		//kinda wish I had a better solution than this
		if (to_check >= params.num_boids || health.data[to_check] <=0) {
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

	if (index < params.num_boids || health.data[index] > 0) {

		int old_head = atomicExchange(bin_mat.data[bindex], index);
		bin_next.data[index] = old_head;
	}
	return;

}



int get_bindex(){


	vec2 bin_pos = (position - vec2(params.bin_offset_x, params.bin_offset_y)) / params.vision_rad;


	int bx = int(floor(bin_pos.x));
    int by = int(floor(bin_pos.y));

	if (bx < 0 || bx >= params.bin_w) return -1;
    if (by < 0 || by >= params.bin_h) return -1;

	return int(bx + (by * params.bin_w));

}

void storeImage(){


	int img_size_int = int(params.image_size);
	ivec2 pixel_pos = ivec2(index % img_size_int, index / img_size_int);
	
	imageStore(boid_data, pixel_pos, vec4(position.x, position.y, velocity.x, velocity.y));
}