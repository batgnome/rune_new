shader_type canvas_item;

uniform float thickness = 1.0;
uniform vec4 outline_color : source_color = vec4(0.0, 0.0, 0.0, 1.0);
uniform bool show_outline = false;
void fragment() {
	if (show_outline){
		
	vec4 tex = texture(TEXTURE, UV);

	if (tex.a < 0.1) {
		bool edge_found = false;
		for (float x = -thickness; x <= thickness && !edge_found; x++) {
			for (float y = -thickness; y <= thickness && !edge_found; y++) {
				vec2 offset_uv = UV + vec2(x, y) / vec2(textureSize(TEXTURE, 0));
				vec4 sample = texture(TEXTURE, offset_uv);
				if (sample.a > 0.1) {
					edge_found = true;
				}
			}
		}
		if (edge_found) {
			COLOR = outline_color;
		} else {
			discard;
		}
	} else {
		COLOR = tex;
	}
	}
}
