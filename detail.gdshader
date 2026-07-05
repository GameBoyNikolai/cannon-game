shader_type spatial;

uniform sampler2D detail;
uniform float detail_strength = 1.0;
uniform vec3 albedo : source_color;

uniform float uv_scale = 1.0;
uniform float blend_sharpness = 1.0; // Higher = sharper transitions

vec4 triplanar_texture(sampler2D samp, vec3 p_world_pos, vec3 p_world_normal) {
    // Determine weights based on surface normal angles
    vec3 blend_weights = abs(p_world_normal);
    blend_weights = pow(blend_weights, vec3(blend_sharpness));
    
    // Normalize weights so they sum up to 1.0
    float total_weight = blend_weights.x + blend_weights.y + blend_weights.z;
    blend_weights /= total_weight;
    
    // Calculate 2D UVs for each projection plane
    vec2 uv_x = p_world_pos.zy; // Project on X axis
    vec2 uv_y = p_world_pos.xz; // Project on Y axis (Top/Bottom)
    vec2 uv_z = p_world_pos.xy; // Project on Z axis
    
    // Sample textures for each plane
    vec4 col_x = texture(samp, uv_x * uv_scale);
    vec4 col_y = texture(samp, uv_y * uv_scale);
    vec4 col_z = texture(samp, uv_z * uv_scale);
    
    // Blend and return final color
    return col_x * blend_weights.x + col_y * blend_weights.y + col_z * blend_weights.z;
}

void fragment() {
    // Get World Position and World Normal (handles both flat & irregular geometry)
    vec3 world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
    vec3 world_normal = normalize(mat3(MODEL_MATRIX) * NORMAL);

	vec4 tex = triplanar_texture(detail, world_pos, world_normal);
	ALBEDO = mix(albedo.rgb, tex.rgb * albedo.rgb, detail_strength);
	//ALPHA = tex.a;
}