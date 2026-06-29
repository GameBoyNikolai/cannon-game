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

float smooth_bump(float start, float end, float fuzz, float x) {
    // Left side ramp up and Right side ramp down
    return smoothstep(start - fuzz, start, x) - 
           smoothstep(end, end + fuzz, x);
}

#if 0
float intensity(float from_angle, vec2 pos) {
	float angle = atan(pos.y, pos.x) + PI;
	//ALBEDO.rgb *= smoothstep(scan_angle - 0.5, scan_angle + 0.5, pix_angle);
	return exp(-mod(from_angle - angle + 2.0 * PI, 2.0 * PI) * 4.0);
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
#else

uniform float scan_time = 0.0;

float intensity(float t, vec2 pos) {
	float pix_dist = distance(pos, vec2(0.0));
	//ALBEDO.rgb *= smoothstep(scan_angle - 0.5, scan_angle + 0.5, pix_angle);
	//return exp(-clamp(scan_time - pix_dist, 0.0, 1.0) * 1.0);
	//return 1.0 - clamp(scan_time - pix_dist, 0.0, 1.0);
	float d_val = (1.0 - clamp(abs(t - pix_dist), 0.0, 1.0)) * (1.0 - ceil(pix_dist - t));
	//return pow(d_val, 10);
	return exp(-10.0 * (1.0 - d_val));
}

void fragment() {
	//float scan_time = mod(TIME, 2.0);
	
	// bottom center
	vec2 pix_pos = UV - vec2(0.5, 0.9);
	
	//ALBEDO.rgb *= smoothstep(scan_angle - 0.5, scan_angle + 0.5, pix_angle);
	float scan_val = clamp(intensity(scan_time, pix_pos), 0.0, 1.0);
	
	float range_extent = 0.7;
	float angle_extent = PI / 2.0;
	
	float pix_dist = distance(pix_pos, vec2(0.0));
	scan_val += smooth_bump(-0.005, 0.005, 0.001, mod(pix_dist, range_extent / float(ranges)));
	
	// get angle, offset slightly in order to center the lines
	float pix_angle = atan(pix_pos.y, pix_pos.x) + PI + 0.01;
	scan_val += smooth_bump(-0.01, 0.01, 0.001, mod(pix_angle - angle_extent / 2.0, angle_extent / float(sectors)));
	
	if (pix_dist > range_extent - 0.01 && pix_dist < range_extent) {
		scan_val = 1.0;
	} else if (pix_dist > range_extent) {
		scan_val = 0.0;
		//ALPHA = 0.0;
	}
	
	// cut out bottom-most layer
	if (pix_dist < range_extent / float(ranges)) {
		scan_val = 0.0;
	}
	
	//pix_angle > angle_extent / 2.0
	if (pix_angle > 0.5 * PI - angle_extent / 2.0 && pix_angle < angle_extent / 2.0 + 0.5 * PI + 0.01) {
		
	} else {
		scan_val = 0.0;
	}
	
	ALBEDO.rgb = vec3(0.0, 1.0, 0.1) * scan_val;
}
#endif