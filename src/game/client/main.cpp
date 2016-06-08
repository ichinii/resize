#include <iostream>

#include <ft2build.h>
#include FT_FREETYPE_H

#include <SFML/Window.hpp>

int main(int argc, char** argv) {
	std::cout << "I am a client!" << std::endl;

	FT_Library  library;
	auto error = FT_Init_FreeType( &library );
	if ( !error )
		std::cout << "Freetype" << std::endl;

	sf::Window window(sf::VideoMode(800, 600), "My window", sf::Style::Close);
	std::cout << "SFML" << std::endl;
	while (window.isOpen())
	{
		window.setActive();

		sf::Event event;
		while (window.pollEvent(event))
		{
		if (event.type == sf::Event::Closed)
			window.close();
		}

		window.display();
	}

	return 0;
}
