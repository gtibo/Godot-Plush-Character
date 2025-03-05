shader_type spatial;
render_mode unshaded, cull_front, shadows_disabled;

uniform vec3 top_color : source_color;
uniform vec3 bottom_color : source_color;

void fragment() {
	ALBEDO = mix(top_color, bottom_color, UV.y);
	DEPTH = (1.0 - FRAGCOORD.z) * 0.001;
}
