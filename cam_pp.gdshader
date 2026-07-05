shader_type spatial;
render_mode unshaded, fog_disabled, cull_disabled;

uniform sampler2D screen_texture : hint_screen_texture;
uniform sampler2D depth_texture : hint_depth_texture;
//uniform sampler2D normal_rough_texture : hint_normal_roughness_texture;

uniform sampler2D distortion;

void vertex() {
	POSITION = vec4(VERTEX.xy, 1.0, 1.0);
}

mat2 rotate2d(float angle) {
    float s = sin(angle);
    float c = cos(angle);
    return mat2(vec2(c, -s), vec2(s, c));
}

vec3 aberrate(float amount, vec2 uv) {
	//vec2 offset = rotate2d(TIME) * amount * vec2(0.005);
	vec2 offset = amount * vec2(0.005);
	
	vec3 color = vec3(1.0);
	//Sample RGB channels individually with offsets
	color.r = texture(screen_texture, uv - offset).r;
	color.g = texture(screen_texture, uv         ).g;
	color.b = texture(screen_texture, uv + offset).b;

	return color;
}

vec3 posterize(in vec3 inputColor){
  float gamma = 0.5f;
  float numColors = 32.0f;
  

  vec3 c = inputColor.rgb;
  c = pow(c, vec3(gamma, gamma, gamma));
  c = c * numColors;
  c = floor(c);
  c = c / numColors;
  c = pow(c, vec3(1.0/gamma));
  
  return c;
}

void fragment() {
	vec4 screen = texture(screen_texture, SCREEN_UV);
	
	float depth_raw = texture(depth_texture, SCREEN_UV).x;
	vec3 ndc = vec3(SCREEN_UV * 2.0 - 1.0, depth_raw);
	vec4 position_view = INV_PROJECTION_MATRIX * vec4(ndc, 1.0);
	position_view.xyz /= position_view.w;
	float linear_depth = -position_view.z;
	
	vec4 world = INV_VIEW_MATRIX * INV_PROJECTION_MATRIX * vec4(ndc, 1.0);
	vec3 position_world = world.xyz / world.w;
	
	//vec4 normal_rough = texture(normal_rough_texture, SCREEN_UV);
	//vec3 normals_view_raw = normal_rough.xyz; // Normals in view space, in [0.0, 1.0] range
	//vec3 normals_view_remapped = normals_view_raw.xyz * 2.0 - 1.0;  // Normals in view space, in [-1.0, 1.0] range
	//vec3 normals_world = (INV_VIEW_MATRIX * vec4(normals_view_remapped, 0.0)).xyz;
	//float roughness = normal_rough.w;
	
	// Visualize the outputs
	// Screen texture
	//ALBEDO.rgb = screen.rgb * min(vec3(1.0), 30.0 * vec3(depth_raw));
	
	//float depth = clamp(50.0 * depth_raw + 0.5, 0.0, 1.0);
	//depth *= depth * depth * depth * depth * depth;
	float depth = clamp(mix(-130.0, 1.0, 1.0 - 1.0 * depth_raw), 0.0, 1.0);
	//ALBEDO.rgb = vec3(depth);
	ALBEDO.rgb = mix(screen.rgb, aberrate(texture(distortion, SCREEN_UV).r * 1.2, SCREEN_UV), depth);
	
	//float depth = clamp(mix(-40.0, 1.0, 1.0 - 1.0 * depth_raw), 0.0, 1.0);
	//ALBEDO.rgb = mix(screen.rgb, posterize(screen.rgb), depth);
	//ALBEDO.rgb = mix(screen.rgb, posterize(screen.rgb * max(texture(distortion, UV + TIME / 100.0).r, -0.1)), 1.0 - depth);
	//ALPHA = screen.a;
	// Raw depths
	//ALBEDO.rgb = vec3(depth_raw);
	// Linear depth
	//ALBEDO.rgb = vec3(fract(linear_depth));
	// World position
	//ALBEDO.rgb = fract(position_world);	
	// Normals from the normal buffer, in view space
	//ALBEDO.rgb = normals_view_raw;
	// Normals in world space, [-1.0,1.0] range
	//ALBEDO.rgb = normals_world;
	// Roughness
	//ALBEDO.rgb = vec3(roughness);
}