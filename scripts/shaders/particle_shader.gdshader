shader_type particles;

uniform sampler2D boid_colors;
uniform sampler2D boid_data;
uniform sampler2D boid_data_prev;
uniform sampler2D health;
uniform float scale = .5;
uniform int phys_fps;
uniform float time_since_phys_step;

float lerp(float start, float fin, float t){return start + (fin - start) * t;}

void process() {
	
	ivec2 pos_image_size = textureSize(boid_data, 0);
	
	//ivec2 texel_pos = ivec2(int(mod(float(INDEX),float(pos_image_size.x))),
	//						int(float(INDEX)/float(pos_image_size.x)));
	ivec2 texel_pos = ivec2(int(INDEX) % pos_image_size.x, (int(INDEX) / pos_image_size.x));
	
	vec4 boid_pos = texelFetch(boid_data, texel_pos, 0);
	vec4 boid_pos_prev = texelFetch(boid_data_prev, texel_pos, 0);
	
	float amt_of_phys_frame_passed = time_since_phys_step / (1.0 / float(phys_fps));
	//float amt_of_phys_frame_passed = time_since_phys_step * float(phys_fps);
	
	amt_of_phys_frame_passed = clamp(amt_of_phys_frame_passed, 0, 1);
	
	
	float x_pos = lerp(boid_pos_prev.r, boid_pos.r, amt_of_phys_frame_passed);
	float y_pos = lerp(boid_pos_prev.g, boid_pos.g, amt_of_phys_frame_passed);
	
	//x_pos = boid_pos.r;
	//y_pos = boid_pos.g;
	
	TRANSFORM[0].xy = vec2(scale, 0);
	TRANSFORM[1].xy = vec2(0, scale);
	TRANSFORM[3].xy = vec2(x_pos, y_pos); 
	
	
	
	//sets color
	COLOR = texelFetch(boid_colors, texel_pos, 0);
	
	vec4 boid_health = texelFetch(health, texel_pos, 0);
	
	if(boid_health.r <= 0.0)
		COLOR.a = 0.0;
	else
		COLOR.rgb *= boid_health.r / 100.0 +.2;
	
		
	
	//else if (is_selected[INDEX])
	//	COLOR = vec4(0.5294118, 0.80784315, 0.92156863, 1);
	//else
	//	COLOR = vec4(0, 0, 0, 1);
}
