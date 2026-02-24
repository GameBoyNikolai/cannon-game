shader_type spatial;

uniform sampler2D metal_tex;
uniform float factor = 0.2;
uniform float scale = 0.1;
uniform vec3 offset = vec3(0.0);

vec3 random(vec3 coord)
{
	vec3 res;
	res.x = fract(sin(dot(coord.yz, vec2(12.9898,78.233))) * 43758.5453123);
	res.y = fract(sin(dot(coord.xz, vec2(16.6539,68.698))) * 69845.5962848);
	res.z = fract(sin(dot(coord.xy, vec2(25.5263,41.256))) * 42538.6985436);
	return res;
}

void fragment() {
	vec3 projected_coords = (INV_VIEW_MATRIX * vec4(VERTEX, 1.0)).xyz + offset;
	vec3 albedoX = texture(metal_tex, projected_coords.zy * scale).rgb;
	vec3 albedoY = texture(metal_tex, projected_coords.xz * scale).rgb;
	vec3 albedoZ = texture(metal_tex, projected_coords.xy * scale).rgb;
	vec3 world_normal = abs(INV_VIEW_MATRIX * vec4(NORMAL, 0.0)).xyz;
	vec3 normal_weights = world_normal / (world_normal.x + world_normal.y + world_normal.z);
	
	vec3 color_offset = random(floor(projected_coords.xyz));
	
	vec3 color = mix(vec3(0.0f), mix((albedoX * normal_weights.x + albedoY * normal_weights.y + albedoZ * normal_weights.z), color_offset.rgb, 0.05f), 1.0);
	
	ALBEDO.rgb = color;
	//ALBEDO.rgb = ALBEDO.rgb * vec3(1.0);
	ALPHA = factor;
}