shader_type spatial;
render_mode unshaded;

uniform vec3 grid_color : source_color = vec3(0.0);
uniform float grid_opacity = 0.1;
uniform float speed_factor = 0.1;
uniform float grid_thickness = 0.1;

float grid(vec2 st, float res, float thickness){
	vec2 grid = mod(st*res + thickness * 0.5, vec2(1.0));
	return (step(thickness, grid.x) * step(thickness, grid.y));
}

void fragment() {
	float mask = smoothstep(0.5, 0.0, distance(vec2(0.5), UV));
	ALPHA = (1.0 - grid(UV + vec2(0.0, TIME * speed_factor), 4.0, grid_thickness)) * mask * grid_opacity;
	ALBEDO = grid_color;
}