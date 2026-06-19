shader_type spatial;
render_mode unshaded, blend_mix, depth_prepass_alpha;

uniform float progress = 0.0;

float intensity(float scan_angle, vec2 pos) {
	float angle = atan(pos.y, pos.x) + PI;
	//ALBEDO.rgb *= smoothstep(scan_angle - 0.5, scan_angle + 0.5, pix_angle);
	return exp(-mod(scan_angle - angle + 2.0 * PI, 2.0 * PI) * 4.0);
}

void fragment() {
	//float len = 2.0;
	//float progress = mod(TIME, len) / len;
	
	vec2 pix_pos = UV - vec2(0.5);
	
	float val = 0.0;
	
	// circle
	float size = 0.12; 
	val += smoothstep(size + 0.01, size - 0.05, distance(pix_pos, vec2(0.0))) * (1.0 - smoothstep(0.8, 1.0, progress));
	
	// wave
	float d = 2.0 * distance(pix_pos, vec2(0.0));
	
	float prog = clamp(progress + 0.4, 0.0, 1.0);
	
	float d_val = (1.0 - clamp(abs(prog - d), 0.0, 1.0)) * (1.0 - ceil(d - prog));
	//val += ceil(d - progress);
	//val = 1.0 - ceil(d - progress);
	
	//val += exp(-d_val);
	val += pow(d_val, 2) * (1.0 - prog);

	
	ALBEDO.rgb = vec3(0.0, 1.0, 0.1) * val;
	ALPHA = val;
}