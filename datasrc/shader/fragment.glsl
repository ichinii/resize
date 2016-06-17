varying vec4 pos;
varying vec4 color;

void main() {
	gl_FragColor = color * (-pos.z * 0.5 + 0.5);
}
