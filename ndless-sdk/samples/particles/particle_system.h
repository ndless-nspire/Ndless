/*****************************************************************************
 * @(#) Ndless - Particle System Demo (Particles manager)
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

#ifndef _PARTICLE_SYSTEM_H_
#define _PARTICLE_SYSTEM_H_

#include "particle.h"

typedef struct {
  bool running;
  bool detectCol;
  bool trace;
  t_particle* particle_head;
  t_particle* particle_tail;
  int nParticles;
} t_particle_system;

extern void particle_system_construct(t_particle_system* t_this);
extern void particle_system_destruct(t_particle_system* t_this);
extern void particle_system_start(t_particle_system* t_this);
extern void particle_system_stop(t_particle_system* t_this);
extern bool particle_system_isRunning(t_particle_system* t_this);
extern bool particle_system_addParticle(t_particle_system* t_this, t_particle* particle);
extern bool particle_system_removeParticle(t_particle_system* t_this, t_particle* particle);

#endif
