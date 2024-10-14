shader_type spatial;

uniform sampler2D albedo_texture : source_color, repeat_disable;
uniform sampler2D normal_texture : hint_normal, repeat_disable;
uniform vec2 uv_offset = vec2(0.0);

float fresnel(float amount, vec3 normal, vec3 view)
{
	return pow((1.0 - clamp(dot(normalize(normal), normalize(view)), 0.0, 1.0 )), amount);
}

void fragment() {
	ALBEDO = texture(albedo_texture, UV + uv_offset).rgb;
	NORMAL_MAP = texture(normal_texture, UV + uv_offset).xyz;
	EMISSION = mix(vec3(1.0), ALBEDO, 0.75) * clamp(smoothstep(0.6, 0.7, fresnel(1.0, NORMAL, VIEW)) * NORMAL.y, 0.0, 1.0) * 2.0;
	ROUGHNESS = 0.7;
	SPECULAR = 0.8;
}
