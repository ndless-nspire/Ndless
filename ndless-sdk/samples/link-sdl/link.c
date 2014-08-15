/*
 *            JUST DO WHATEVER THE FUCK YOU WANNA DO PUBLIC LICENSE
 *                         Version 1, January 2013
 * 
 *   Copyright (C) 2013 Christoffer Rehn <crehn@outlook.com>
 * 
 *   Everyone is permitted to copy and distribute verbatim or modified copies
 * of this license document, and changing it is allowed.
 * 
 *          JUST DO WHATEVER THE FUCK YOU WANNA DO PUBLIC LICENSE
 *     TERMS AND CONDITIONS FOR COPYING, DISTRIBUTION AND MODIFICATION
 * 
 *   0. Just do whatever the fuck you wanna do. Seriously.
 */

#include <os.h>
#include <SDL/SDL.h>
#include "link.h"
#include "map1.h"

SDL_Surface *screen;
nSDL_Font *font;
SDL_bool done = SDL_FALSE;
int num_moves = 0;
player_t player;
map_t map;

void init(void) {
    if(SDL_Init(SDL_INIT_VIDEO) == -1) {
        printf("Couldn't initialize SDL: %s\n", SDL_GetError());
        exit(EXIT_FAILURE);
    }
    screen = SDL_SetVideoMode(320, 240, has_colors ? 16 : 8, SDL_SWSURFACE);
    if(screen == NULL) {
        printf("Couldn't initialize display: %s\n", SDL_GetError());
        SDL_Quit();
        exit(EXIT_FAILURE);
    }
    SDL_ShowCursor(SDL_DISABLE);
}

void quit(void) {
    SDL_FreeSurface(player.sprite);
    SDL_FreeSurface(map.tileset);
    SDL_Quit();
}

void init_player(int x, int y, dir_t direction, SDL_Surface *sprite) {
    SDL_SetColorKey(sprite,
                    SDL_SRCCOLORKEY | SDL_RLEACCEL,
                    SDL_MapRGB(sprite->format, 255, 0, 255));
    player.x = x;
    player.y = y;
    player.direction = direction;
    player.sprite = sprite;
}

void init_map(char **data,
              int width, int height,
              int num_tiles,
              SDL_Surface *tileset,
              tile_attrib_t *tile_attrib) {
    map.data = data;
    map.width = width;
    map.height = height;
    map.num_tiles = num_tiles;
    map.tileset = tileset;
    map.tile_attrib = tile_attrib;
}

/* This function isn't actually used, but if BMP images were used, load_bmp()
   would load the BMP image and convert it to an optimized format (read: same
   pixel format as the display). */
SDL_Surface *load_bmp(const char *file) {
    SDL_Surface *tmp, *image;
    tmp = SDL_LoadBMP(file);
    if(tmp == NULL)
        return NULL;
    image = SDL_DisplayFormat(tmp);
    SDL_FreeSurface(tmp);
    return image;
}

void draw_tile(SDL_Surface *tileset, int tile_num, int x, int y) {
    SDL_Rect src_rect, screen_pos;
    src_rect.x = tile_num * TILE_WIDTH;
    src_rect.y = 0;
    src_rect.w = TILE_WIDTH;
    src_rect.h = TILE_HEIGHT;
    screen_pos.x = x * TILE_WIDTH;
    screen_pos.y = y * TILE_HEIGHT;
    SDL_BlitSurface(tileset, &src_rect, screen, &screen_pos);
}

void draw_player(void) {
    draw_tile(player.sprite, (int)player.direction, player.x, player.y);
}

void draw_tile_map(void) {
    int i, j;
    for(i = 0; i < map.height; ++i)
        for(j = 0; j < map.width; ++j)
            draw_tile(map.tileset, map.data[i][j] - 'A', j, i);
}

void draw_info(void) {
    SDL_Rect rect = {0, 224, 320, 16};
    SDL_FillRect(screen, &rect, SDL_MapRGB(screen->format, 32, 0, 0));
    nSDL_DrawString(screen, font, 4, 228, "Moves: %d", num_moves);
    nSDL_DrawString(screen, font,
                    SCREEN_WIDTH - nSDL_GetStringWidth(font, "nSDL " NSDL_VERSION) - 4, 228,
                    "nSDL " NSDL_VERSION);
}

SDL_bool is_walkable(int x, int y) {
    return map.tile_attrib[(int)map.data[y][x] - 'A'].is_walkable;
}

void move_player(dir_t direction) {
    if(player.direction == direction) {
        int prev_x = player.x;
        int prev_y = player.y;
        switch(direction) {
            case UP:
                --player.y;
                break;
            case DOWN:
                ++player.y;
                break;
            case LEFT:
                --player.x;
                break;
            case RIGHT:
                ++player.x;
                break;
        }
        if(!is_walkable(player.x, player.y)) {
            player.x = prev_x;
            player.y = prev_y;
        } else
            ++num_moves;
    } else
        player.direction = direction;
}

void handle_keydown(SDLKey key) {
    switch(key) {
        case SDLK_UP:
            move_player(UP);
            break;
        case SDLK_DOWN:
            move_player(DOWN);
            break;
        case SDLK_LEFT:
            move_player(LEFT);
            break;
        case SDLK_RIGHT:
            move_player(RIGHT);
            break;
        case SDLK_KP_ENTER: /* This corresponds to the "click button" on the TI-Nspire. */
        case SDLK_RETURN:
            if(player.x == 14 && player.y == 8 && player.direction == UP)
                num_moves = 1337;
            break;
        case SDLK_ESCAPE:
            done = SDL_TRUE;
            break;
        default:
            break;
    }
}

int main(void) {
    init();
    /* quit() takes care of freeing the next two images. */
    init_player(10, 7, DOWN, nSDL_LoadImage(image_link));
    init_map(map1_data, MAP1_WIDTH, MAP1_HEIGHT, MAP1_NUM_TILES,
             nSDL_LoadImage(image_tileset), map1_tile_attrib);
    if (player.sprite == NULL || map.tileset == NULL)
        return EXIT_FAILURE;
    font = nSDL_LoadFont(NSDL_FONT_TINYTYPE, 255, 255, 255);
    SDL_EnableKeyRepeat(SDL_DEFAULT_REPEAT_DELAY, SDL_DEFAULT_REPEAT_INTERVAL);
    while(!done) {
        SDL_Event event;
        draw_tile_map();
        draw_player();
        draw_info();
        SDL_Flip(screen);
        SDL_WaitEvent(&event);
        switch(event.type) {
            case SDL_KEYDOWN:
                handle_keydown(event.key.keysym.sym);
                break;
            default:
                break;
        }
    }
    nSDL_FreeFont(font);
    quit();
    return EXIT_SUCCESS;
}
