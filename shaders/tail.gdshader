shader_type canvas_item;

uniform sampler2D mask_texture;
uniform vec2 mask_offset = vec2(0.0, 0.0);

void fragment() {
	vec4 mask = texture(mask_texture, UV -mask_offset);

	bool mask_visible = mask.r < 0.1 && mask.g < 0.1 && mask.b < 0.1 && mask.a > 0.1;
	
	if (!mask_visible) {
		discard;
	}

}
