/*****************************************************************************
 * @(#) Ndless - Particle System Demo (User class)
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

#ifndef _GRAVITY_PARTICLES_H_
#define _GRAVITY_PARTICLES_H_

#include "particle_system.h"
#include "utils.h"

typedef struct {
  t_particle_system particleSystem;
  float gravitationalConstant;
  //private ParticleComparer pc = new ParticleComparer();
  int accelerationMultiplier;
} t_gravity_particles;

extern void gravity_particles_construct(t_gravity_particles* t_this, float gravity, int accelerationMultiplier);
extern void gravity_particles_destruct(t_gravity_particles* t_this);
extern t_particle* gravity_particles_merge(t_gravity_particles* t_this, t_particle* i, t_particle* j);
extern void gravity_particles_draw(t_gravity_particles* t_this);
extern void add_particle(t_gravity_particles* gravity_particles);
extern void remove_particle(t_gravity_particles* gravity_particles);

#endif
