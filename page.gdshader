shader_type spatial;
render_mode cull_disabled;

uniform sampler2D tex;
uniform sampler2D ramp : repeat_disable;
uniform float factor;

uniform float turn = 0.0;

uniform vec3 page_color : source_color;

void vertex() {
	// Called for every vertex the material is visible on.
	VERTEX += vec4(0.0, factor * texture(ramp, vec2(UV.x, 0.0)).r, 0.0, 0.0).xyz;
}

void fragment() {
	if (FRONT_FACING) {
		ALBEDO = pow(texture(tex, UV).rgb, vec3(2.2));
		ALPHA = 1.0;
	} else {
		ALBEDO = page_color;
		ALPHA = 1.0;
	}
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
