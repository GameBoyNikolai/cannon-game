shader_type spatial;
render_mode unshaded, blend_mix, depth_prepass_alpha;

uniform float scan_angle = 0.0;

uniform vec2 pings[10];
uniform int num_pings;

uniform int sectors;
uniform int ranges;

float angle_dist(float a, vec2 pos) {
	float angle = atan(pos.y, pos.x) + PI;
	return mod(a - angle + 2.0 * PI, 2.0 * PI);
}

float intensity(float from_angle, vec2 pos) {
	float angle = atan(pos.y, pos.x) + PI;
	//ALBEDO.rgb *= smoothstep(scan_angle - 0.5, scan_angle + 0.5, pix_angle);
	return exp(-mod(from_angle - angle + 2.0 * PI, 2.0 * PI) * 4.0);
}

float smooth_bump(float start, float end, float fuzz, float x) {
    // Left side ramp up and Right side ramp down
    return smoothstep(start - fuzz, start, x) - 
           smoothstep(end, end + fuzz, x);
}

void fragment() {
	//scan_angle = 3.0 * TIME;
	//scan_angle = mod(scan_angle, 2.0 * PI);
	
	//ALBEDO = vec3(0.0);
	
	vec2 pix_pos = UV - vec2(0.5);
	
	//ALBEDO.rgb *= smoothstep(scan_angle - 0.5, scan_angle + 0.5, pix_angle);
	float scan_val = intensity(scan_angle, pix_pos);
	
	for (int i = 0; i < num_pings; ++i) {
		vec2 ping_pos = pings[i];
		
		float dist = angle_dist(scan_angle, ping_pos);
		if (dist < 5.0 * PI / 4.0) {
			float size = mix(0.0, 0.005,  5.0 * PI / 4.0 - dist);
			//if (distance(ping_pos, pix_pos) < 0.03 / 2.0) {
				//ALBEDO.rgb += vec3(size / 0.05);
			//}
			scan_val += smoothstep(size + 0.005, size - 0.005, distance(ping_pos, pix_pos));
		}
	}
	
	float pix_dist = distance(pix_pos, vec2(0.0));
	scan_val += smooth_bump(-0.005, 0.005, 0.001, mod(pix_dist, 0.5 / float(ranges)));
	
	float pix_angle = atan(pix_pos.y, pix_pos.x) + PI;
	scan_val += smooth_bump(-0.02, 0.02, 0.001, mod(pix_angle, 2.0 * PI / float(sectors)));
	
	if (pix_dist > 0.5 - 0.01 && pix_dist < 0.5) {
		scan_val = 1.0;
	} else if (pix_dist > 0.5) {
		scan_val = 0.0;
		//ALPHA = 0.0;
	}
	
	ALBEDO.rgb = vec3(0.0, 1.0, 0.1) * scan_val;
}
