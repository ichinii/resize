attribute vec3 vertexPosition;
attribute vec3 vertexColor;

varying vec4 color;

void main() {
	color = vec4(vertexColor, 1);
	gl_Position = vec4(vertexPosition, 1);
}
