shader_type canvas_item;

uniform sampler2D Level1;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	// Called for every pixel the material is visible on.
	COLOR = vec4(0.0, 0.0, 0.0, 1.0);
	COLOR = texture(Level1,UV);

}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
