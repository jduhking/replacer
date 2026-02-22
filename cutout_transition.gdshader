shader_type canvas_item;

uniform sampler2D mask;
uniform float scale : hint_range(0.0, 1.0, 0.1);


void fragment() {
	// Called for every pixel the material is visible on.
	float s = scale * scale * scale * scale * scale;
	s *= 75.0f;
	int cutoff = int(s / 75.0f);
	vec2 offset = vec2(0.5, 0.5) * (1.0 - s);
	vec4 mask_color = texture(mask, UV * s + offset);
	COLOR.a = 1.0 - mask_color.a + float(cutoff);
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}