shader_type spatial;
render_mode unshaded;

uniform sampler2D screen_texture : hint_screen_texture;

uniform vec4 outline_color: source_color = vec4(0.771, 0.755, 0.0, 1.0);
uniform float outline_width = 6.0;

uniform float density = 1.0;

#define PHI 1.618034
#define TAU 6.283185

//Golden Angle, Tau*(2-Phi)
#define G_A 2.399963
//Half pi, Tau/4.0
#define HPI 1.570796

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
    float dot_amt = 1.0 - smoothstep(radius - 0.1, radius + 0.1, dist);
	
	return dot_amt;
}

float phidot(vec2 uv) {
	float dot_amt = 0.0;
	
	float scale = 20.0;
    vec2 p = uv * scale;
	p.x *= 16.0/9.0;
	
	int n = 300;
	for (int i = 0; i < n; ++i) {
		vec2 pos = vec2(float(i)/float(n), fract(float(i)*PHI)) * vec2(16.0, 9.0) * 2.5;
		
	    float dist = distance(pos, p);
    
	    // Create dot with smooth edges
	    float radius = 0.15 * mix(0.3, 1.0, 0.5 * (sin(2.0 * TIME) + 1.0)); // Size of the dot
	    dot_amt += 1.0 - smoothstep(radius - 0.1, radius + 0.1, dist);
	}
	
	return dot_amt;
} 

float phispiral(vec2 uv) {
	float dot_amt = 0.0;
	
	float scale = 20.0;
    vec2 p = (uv - vec2(0.5)) * scale;
	p.x *= 16.0/9.0;
	
	float r = 20.0;
	
	int n = int(300.0 * density);
	for (int i = 0; i < n; ++i) {
		//vec2 pos = vec2(float(i)/float(n), fract(float(i)*PHI)) * vec2(16.0, 9.0) * 2.5;
		vec2 pos = cos(float(i) * G_A + vec2(0.0, HPI)) * sqrt(float(i)/float(n)) * r;
		
	    float dist = distance(pos, p);
    
	    // Create dot with smooth edges
	    float radius = 0.15 * mix(0.3, 1.0, 0.5 * (sin(2.0 * TIME) + 1.0)); // Size of the dot
	    dot_amt += 1.0 - smoothstep(radius - 0.1, radius + 0.1, dist);
	}
	
	return dot_amt;
}

void fragment() {
	//ALBEDO = outline_color.rgb;
	//if (outline_color.a < 1.0) {
		//ALPHA = outline_color.a;
	//}
	
	//float p = polka(SCREEN_UV) * 0.5 * (sin(TIME) + 1.0);	
	//float p = phidot(SCREEN_UV);// * mix(0.3, 1.0, 0.5 * (sin(2.0 * TIME) + 1.0));
	float p = phispiral(SCREEN_UV);
	
    vec3 color = mix(texture(screen_texture, SCREEN_UV).rgb, outline_color.rgb, p);
    ALBEDO = color;
	ALPHA = p;
}
