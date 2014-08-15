/*****************************************************************************
 * Copyright (C) 2010 by ANNEHEIM Geoffrey
 * Contact: geoffrey.anneheim@gmail.com
 *
 * Original code by BoneSoft:
 * http://www.codeproject.com/KB/GDI-plus/FunWithGravity.aspx
 *
 * This program is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
 * or FITNESS FOR A PARTICULAR PURPOSE.
 *
 * RCSID $Id$
 *****************************************************************************/

#include <os.h>
#include "utils.h"
#include "particle.h"

void particle_construct(t_particle* t_this, bool allocated) {
  vector_construct(&(t_this->acceleration));
  vector_construct(&(t_this->velocity));
  vector_construct(&(t_this->location));
  t_this->mass = 0.f;
  t_this->size = 1;
  t_this->color = BLACK;
  t_this->allocated = allocated;
  t_this->child = NULL;
  t_this->parent = NULL;
  t_this->xScreen = SCREEN_WIDTH >> 1;
  t_this->yScreen = SCREEN_HEIGHT >> 1;
}

void particle_destruct(__attribute__((unused)) t_particle* t_this) {

}

void particle_construct2(t_particle* t_this, bool allocated, const t_vector* loc, const t_vector* vel, float mass, int size, int color) {
  particle_construct(t_this, allocated);

  t_this->location = *loc;
  t_this->velocity = *vel;
  t_this->mass = mass;
  t_this->color = color;
  t_this->size = size;
  particle_update(t_this);
}

t_particle* particle_construct3(const t_vector* loc, const t_vector* vel, float mass, int size, int color) {
  t_particle* p;
  p = (t_particle*)malloc(sizeof(t_particle));
  particle_construct2(p, true, loc, vel, mass, size, color);
  return p;
}

void particle_update(t_particle* t_this) {
  t_this->location = vector_add(&(t_this->location), &(t_this->velocity));
  t_this->xScreen = ((t_this->location.x + 5000.f) * 0.032f) - (t_this->size >> 1);
  t_this->yScreen = ((t_this->location.y + 5000.f) * 0.024f) - (t_this->size >> 1);
}

t_vector particle_midLocation(t_particle* t_this) {
  float s = (float)t_this->size / 2.f;
  t_vector v;
  vector_construct2(&v, t_this->location.x + s, t_this->location.y + s, t_this->location.z + s);
  return v;
}

int particle_comparer(t_particle* p1, t_particle* p2) {
  if (!p1 && !p2) return 0;
  if (p1 && !p2) return -1;
  if (!p1 && p2) return 1;

  return (p1->location.z - p2->location.z);
}

void particle_draw(__attribute__((unused)) t_particle* t_this, int color) {
  int x = t_this->xScreen;
  int y = t_this->yScreen;
  unsigned char* s = (unsigned char*)(SCREEN_BASE_ADDRESS + ((x >> 1) + (y << 7) + (y << 5)));

  if ((x < 0) || (x > (SCREEN_WIDTH - 4)) || (y < 0) || (y > (SCREEN_HEIGHT - 4))) {
    return;
  }

  if (x & 1) {
    *(s + 1) = color | (color << 4);
    s += (SCREEN_WIDTH >> 1);

    *s = (*s & 0xF0) | color;
    *(s + 1) = color | (color << 4);
    *(s + 2) = (*(s + 2) & 0x0F) | (color << 4);
    s += (SCREEN_WIDTH >> 1);

    *s = (*s & 0xF0) | color;
    *(s + 1) = (color << 4) | color;
    *(s + 2) = (*(s + 2) & 0x0F) | (color << 4);
    s += (SCREEN_WIDTH >> 1);

    *(s + 1) = color | (color << 4);
  }
  else {
    *s = (*s & 0xF0) | color;
    *(s + 1) = (*(s + 1) & 0x0F) | (color << 4);
    s += (SCREEN_WIDTH >> 1);

    *s = (color << 4) | color;
    *(s + 1) = (color << 4) | color;
    s += (SCREEN_WIDTH >> 1);

    *s = (color << 4) | color;
    *(s + 1) = (color << 4) | color;
    s += (SCREEN_WIDTH >> 1);

    *s = (*s & 0xF0) | color;
    *(s + 1) = (*(s + 1) & 0x0F) | (color << 4);
  }
}
