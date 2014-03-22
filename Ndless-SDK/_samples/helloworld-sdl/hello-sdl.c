#include <os.h>
#include <SDL/SDL_config.h>
#include <SDL/SDL.h>


int main(void) {
	SDL_Surface *screen;
	nSDL_Font *font;
	SDL_Init(SDL_INIT_VIDEO);
	screen = SDL_SetVideoMode(320, 240, has_colors ? 16 : 8, SDL_SWSURFACE);
	font = nSDL_LoadFont(NSDL_FONT_TINYTYPE,
	                     29, 43, 61);
	SDL_FillRect(screen, NULL, SDL_MapRGB(screen->format, 184, 200, 222));
	nSDL_DrawString(screen, font, 10, 10, "Hello, world! \x1");
	SDL_Flip(screen);
	SDL_Delay(3000);
	SDL_Quit();
	return 0;
}
