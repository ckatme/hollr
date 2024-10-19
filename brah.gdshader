shader_type spatial;
uniform sampler2DArray tex : filter_nearest_mipmap;
varying flat int index;
void vertex() {
	index = int(UV2.x);
}

void fragment() {
	vec4 sampleColor = texture(tex, vec3(UV.x,UV.y,float(index)));
	ALBEDO = sampleColor.rgb;
}

//void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
//}
