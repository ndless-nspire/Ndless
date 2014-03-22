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

#ifndef MAP1_H
#define MAP1_H

#include <SDL/SDL.h>
#include "link.h"

#define MAP1_WIDTH  20
#define MAP1_HEIGHT 14

#define MAP1_NUM_TILES 24

/* Every character is mapped to a certain tile, as you might have guessed. */
static char *map1_data[MAP1_HEIGHT] = {
    "NMNMNMNMNMNMNMNMNMNM",
    "OABAACABAAAAADAAABAO",
    "OAAFFJFFAAAABAAAAAAO",
    "OAAFFJFFAAAAKLKLACAO",
    "OACJJJJJAAAAMNMNABAO",
    "OAAFFJFFAAADKLKLAAAO",
    "OAAFFJFFABACMNMNADAO",
    "OAAADAAAAAAAACGAAAAO",
    "OAAAAPQAAAAAABAAAAAO",
    "OAAAPXRAAABHHHAAABAO",
    "OABPXXTAAAAHIHAAAAAO",
    "OAASWTAAEAAHHHAAAABO",
    "OAAAACAAABAACAAAAAAO",
    "LKLKLKLKLKLKLKLKLKLK"
};

/* This structure defines which tiles are walkable and which aren't. It could
   have been made much simpler but it would've been much less flexible. */
tile_attrib_t map1_tile_attrib[MAP1_NUM_TILES] = {
    {SDL_TRUE},  /* A */
    {SDL_TRUE},  /* B */
    {SDL_TRUE},  /* C */
    {SDL_TRUE},  /* D */
    {SDL_FALSE}, /* E */
    {SDL_FALSE}, /* F */
    {SDL_FALSE}, /* G */
    {SDL_TRUE},  /* H */
    {SDL_FALSE}, /* I */
    {SDL_TRUE},  /* J */
    {SDL_FALSE}, /* K */
    {SDL_FALSE}, /* L */
    {SDL_FALSE}, /* M */
    {SDL_FALSE}, /* N */
    {SDL_FALSE}, /* O */
    {SDL_TRUE},  /* P */
    {SDL_TRUE},  /* Q */
    {SDL_TRUE},  /* R */
    {SDL_TRUE},  /* S */
    {SDL_TRUE},  /* T */
    {SDL_TRUE},  /* U */
    {SDL_TRUE},  /* V */
    {SDL_TRUE},  /* W */
    {SDL_TRUE},  /* X */
};

#endif