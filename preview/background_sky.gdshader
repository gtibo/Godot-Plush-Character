shader_type spatial;
render_mode unshaded, cull_front, shadows_disabled;

void fragment() {
	ALBEDO = mix(vec3(0.2), vec3(0.1), UV.y);
	DEPTH = (1.0 - FRAGCOORD.z) * 0.001;
}
