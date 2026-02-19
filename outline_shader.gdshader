shader_type spatial;
render_mode unshaded;

uniform vec4 outline_color: source_color = vec4(0.671, 0.655, 0.0, 1.0);
uniform float outline_width = 6.0;

//void vertex() {
	//vec4 clip_position = PROJECTION_MATRIX * (MODELVIEW_MATRIX * vec4(VERTEX, 1.0));
	//vec3 clip_normal = mat3(PROJECTION_MATRIX) * (mat3(MODELVIEW_MATRIX) * NORMAL);
	//
	//vec2 offset = normalize(clip_normal.xy) / VIEWPORT_SIZE * clip_position.w * outline_width * 2.0;
	//
	//clip_position.xy += offset;
	//
	//POSITION = clip_position;
//}


float polka(vec2 uv) {
	float scale = 20.0;
    vec2 p = uv * scale;
	p.x *= 16.0/9.0;
    vec2 grid = fract(p) - 0.5; // Local coordinate (-0.5 to 0.5)
    
    // Distance from center of grid cell
    float dist = length(grid);
    
    // Create dot with smooth edges
    float radius = 0.15; // Size of the dot
    float dot_amt = 1.0 - smoothstep(radius - 0.05, radius + 0.05, dist);
	
	return dot_amt;
}

void fragment() {
	//ALBEDO = outline_color.rgb;
	//if (outline_color.a < 1.0) {
		//ALPHA = outline_color.a;
	//}
	
	float p = polka(SCREEN_UV);	
	
    vec3 color = mix(ALBEDO, outline_color.rgb, p);
    ALBEDO = color;
	ALPHA = p;
}
