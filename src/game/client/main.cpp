#include <iostream>
#include <string>
#include <cstring>
#include <fstream>

#include <GL/glew.h>
#include <SFML/Window.hpp>
#include <glm/glm.hpp>

GLuint loadShaderFromFile(GLuint shaderType, const char* filepath) {
	GLuint shaderID = glCreateShader(shaderType);

	std::string code;
	std::ifstream stream(filepath, std::ios::in);
	if(stream.is_open()) {
		std::string line;
		while(std::getline(stream, line))
			code += line + '\n';
		stream.close();
	} else {
		printf("Could not open shader file: %s\n", filepath);
		return 0;
	}

	const char* str = code.c_str();
	glShaderSource(shaderID, 1, &str, nullptr);
	glCompileShader(shaderID);

	GLint result;
	int infoLogLength;
	glGetShaderiv(shaderID, GL_COMPILE_STATUS, &result);
	glGetShaderiv(shaderID, GL_INFO_LOG_LENGTH, &infoLogLength);
	if ( infoLogLength > 1 ) {
		char errorMessage[infoLogLength + 1];
		glGetShaderInfoLog(shaderID, infoLogLength, nullptr, &errorMessage[0]);
		printf("Error while compiling shader: %s\n%s\n", filepath, &errorMessage[0]);
	}

	return shaderID;
}

void printGLErrors() {
	static int i = 0;
	GLenum err = GL_NO_ERROR;
	while((err = glGetError()) != GL_NO_ERROR)
	{
		std::cout << i++ << ": 0x" << std::hex << err << std::endl;
	}
}
int main(int argc, char** argv) {
	std::cout << "I am a client!" << std::endl;
	size_t storageLength = strlen(argv[0]);
	char storage[storageLength];
	strcpy(storage, argv[0]);
	for(int i = storageLength - 1; i >= 0 && storage[i] != '/'; i--)
		storage[i] = '\0';

	sf::ContextSettings settings;
	settings.depthBits = 24;
	settings.stencilBits = 8;
	settings.antialiasingLevel = 0;
	sf::Window window(sf::VideoMode(1280, 720), "Sample", sf::Style::Close, settings);

	window.setActive();
	glewInit();

	glClearColor(.1f, .2f, .3f, 1.f);
	glEnable(GL_CULL_FACE);
	glEnable(GL_DEPTH_TEST);

	GLuint vertexShaderID = loadShaderFromFile(
		GL_VERTEX_SHADER,
		(std::string(storage) + "data/shader/vertex.glsl").c_str()
	);
	GLuint fragmentShaderID = loadShaderFromFile(
		GL_FRAGMENT_SHADER,
		(std::string(storage) + "data/shader/fragment.glsl").c_str()
	);
	GLuint programID = glCreateProgram();
	glAttachShader(programID, vertexShaderID);
	glAttachShader(programID, fragmentShaderID);
	glLinkProgram(programID);

	int result;
	int infoLogLength;
	glGetProgramiv(programID, GL_LINK_STATUS, &result);
	glGetProgramiv(programID, GL_INFO_LOG_LENGTH, &infoLogLength);
	if ( infoLogLength > 1 ) {
		char errorMessage[infoLogLength + 1];
		glGetProgramInfoLog(programID, infoLogLength, NULL, &errorMessage[0]);
		printf("%s\n", &errorMessage[0]);
	}

	glUseProgram(programID);
	glDetachShader(programID, vertexShaderID);
	glDetachShader(programID, fragmentShaderID);
	glDeleteShader(vertexShaderID);
	glDeleteShader(fragmentShaderID);

	glm::vec3 vertices[] {
		{-1,  -1,  1},
		{ 1,  -1,  1},
		{ 0, .6,  -1},

		{-1, -.6, -1},
		{ 1, -.6, -1},
		{ 0,   1,  1},
	};

	glm::vec3 colors[] {
		{1, 0, 0},
		{1, 0, 0},
		{1, 0, 0},

		{0, 1, 0},
		{0, 1, 0},
		{0, 1, 0},
	};

	GLuint attribVertexPosition = glGetAttribLocation(programID, "vertexPosition");
	GLuint attribVertexColor = glGetAttribLocation(programID, "vertexColor");

	GLuint vao;
	glGenVertexArrays(1, &vao);
	glBindVertexArray(vao);

	GLuint vbo[2];
	glGenBuffers(2, vbo);

	glEnableVertexAttribArray(attribVertexPosition);
	glBindBuffer(GL_ARRAY_BUFFER, vbo[0]);
	glBufferData(GL_ARRAY_BUFFER, sizeof(vertices), vertices, GL_STATIC_DRAW);
	glVertexAttribPointer(
		attribVertexPosition,
		3,
		GL_FLOAT,
		GL_FALSE,
		sizeof(float) * 3,
		nullptr
	);
	glEnableVertexAttribArray(attribVertexColor);
	glBindBuffer(GL_ARRAY_BUFFER, vbo[1]);
	glBufferData(GL_ARRAY_BUFFER, sizeof(colors), colors, GL_STATIC_DRAW);
	glVertexAttribPointer(
		attribVertexColor,
		3,
		GL_FLOAT,
		GL_FALSE,
		sizeof(float) * 3,
		nullptr
	);
	glBindVertexArray(0);

	while(window.isOpen()) {
		glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

		glBindVertexArray(vao);
		glDrawArrays(GL_TRIANGLES, 0, 6);
		glBindVertexArray(0);

		window.display();

		sf::Event event;
		while(window.pollEvent(event)) {
			if(event.type == sf::Event::Closed 
			|| (event.type == sf::Event::KeyPressed 
			&& event.key.code == sf::Keyboard::Q)) {
				window.close();
			}
		}
	}

	printGLErrors();

	return 0;
}
