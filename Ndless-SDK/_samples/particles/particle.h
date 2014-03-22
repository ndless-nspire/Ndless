/*****************************************************************************
 * @(#) Ndless - Particle System Demo (Particle class)
 *
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

#ifndef _PARTICLE_H_
#define _PARTICLE_H_

#include "vector.h"
#include "utils.h"

typedef struct s_particle {
  t_vector location;
  t_vector velocity;
  t_vector acceleration;
  float mass;
  int size;
  int color;
  bool allocated;
  struct s_particle* child;
  struct s_particle* parent;

  int xScreen, yScreen;
} t_particle;

extern void particle_construct(t_particle* t_this, bool allocated);
extern void particle_destruct(t_particle* t_this);
extern void particle_construct2(t_particle* t_this, bool allocated, const t_vector* loc, const t_vector* vel, float mass, int size, int color);
extern t_particle* particle_construct3(const t_vector* loc, const t_vector* vel, float mass, int size, int color);
extern void particle_update(t_particle* t_this);
extern t_vector particle_midLocation(t_particle* t_this);
extern int particle_comparer(t_particle* p1, t_particle* p2);
extern void particle_draw(t_particle* t_this, int color);

#endif
