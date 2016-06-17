attribute vec3 vertexPosition;
attribute vec3 vertexColor;

varying vec4 pos;
varying vec4 color;

void main() {
	pos = vec4(vertexPosition, 1);
	color = vec4(vertexColor, 1);
	gl_Position = pos;
}
