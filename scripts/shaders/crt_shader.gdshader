/*
Godot 3 2D CRT Shader.
A 2D shader for Godot 3 simulating a CRT..

Author: hiulit
Repository: https://github.com/hiulit/Godot-3-2D-CRT-Shader
Issues: https://github.com/hiulit/Godot-3-2D-CRT-Shader/issues
License: MIT https://github.com/hiulit/Godot-3-2D-CRT-Shader/blob/master/LICENSE

Modified to work in Godot 4, and changed a bit to fit my needs
*/


shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;
uniform vec2 curve_factor= vec2(1, 1);
uniform vec2 screen_size = vec2(640, 360);
uniform bool show_curvature = true;
uniform vec4 corner_color;
uniform bool show_vignette = true;
uniform float vignette_opacity : hint_range(0.0, 1.0, 0.01) = 0.2;
uniform bool show_horizontal_scan_lines = true;
uniform float horizontal_scan_lines_amount : hint_range(0.0, 180.0, 0.1) = 180.0;
uniform float horizontal_scan_lines_opacity : hint_range(0.0, 1.0, 0.01) = .1;
uniform bool show_vertical_scan_lines = false;
uniform float vertical_scan_lines_amount : hint_range(0.0, 320.0, 0.1) = 320.0;
uniform float vertical_scan_lines_opacity : hint_range(0.0, 1.0, 0.01) = .02;
uniform float boost : hint_range(1.0, 5.0, 0.01) = 1.4;
uniform float aberration_amount : hint_range(0.0, 10.0, 0.01) = 1.0;

vec2 apply_curve(vec2 uv){
	
	if(!show_curvature)
		return uv;
	
    // curvature follows cubic funciton
    uv = uv * 2.0 - 1.0;
    vec2 offset = abs(uv.yx) / curve_factor;
    return (uv + uv * offset * offset) * 0.5 + 0.5;
}

float avg(float a, float b){return (a+b)/2.0;}

void vertex() {
	// Called for every vertex the material is visible on.
	
}

void fragment() {
	// Called for every pixel the material is visible on.
	
	vec2 uv = apply_curve(UV);
	vec2 screen_uv = apply_curve(SCREEN_UV);
	vec3 color = texture(SCREEN_TEXTURE, screen_uv).rgb;
	
	if (show_vignette) {
		float vignette = uv.x * uv.y * (1.0 - uv.x) * (1.0 - uv.y);
		vignette = clamp(pow((screen_size.x / 4.0) * vignette, vignette_opacity), 0.0, 1.0);
		color *= vignette;
	}

	if (show_horizontal_scan_lines) {
		float s = sin(screen_uv.y * horizontal_scan_lines_amount * PI * 2.0);
		//s = (s * 0.5 + 0.5) * 0.9 + 0.1;
		
		s = clamp((s) * 2.0, 0.01, 1.0);
		
		color.rgb *= pow(s, horizontal_scan_lines_opacity);
	}

	if (show_vertical_scan_lines) {
		float s = sin(screen_uv.x * vertical_scan_lines_amount * PI * 2.0);
		//s = (s * 0.5 + 0.5) * 0.9 + 0.1;
		s = clamp((s) * 2.0, 0.01, 1.0);
		color.rgb *= pow(s, vertical_scan_lines_opacity);
	}

	if (show_horizontal_scan_lines || show_vertical_scan_lines) {
		color *= boost;
	}

	// Fill the blank space of the corners, left by the curvature, with black.
	if (uv.x < 0.0 || uv.x > 1.0 || uv.y < 0.0 || uv.y > 1.0) {
		color = corner_color.rgb;
	}
	
	else if (aberration_amount > 0.0) {
		
		float adjusted_amount = aberration_amount / screen_size.x;
		color.r = avg(texture(SCREEN_TEXTURE, vec2(screen_uv.x + adjusted_amount, screen_uv.y)).r, color.r);
		color.g = avg(texture(SCREEN_TEXTURE, screen_uv).g, color.g);
		color.b = avg(texture(SCREEN_TEXTURE, vec2(screen_uv.x - adjusted_amount, screen_uv.y)).b, color.b);
	}
	
	COLOR = vec4(color, 1.0);
}




//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
