shader_type canvas_item;
uniform float noise_intensity = .1;

float rand(vec2 uv){
	return fract(sin(dot(uv, reflect(uv, vec2(TIME, TIME)))) * 43758.5453);
}

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	// Called for every pixel the material is visible on.
	//if noise
	
	COLOR.rgb = vec3(0, 0, 0);
	COLOR.rgb += rand(UV);
	COLOR.a = noise_intensity;
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
