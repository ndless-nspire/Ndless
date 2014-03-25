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
#include "particle_system.h"

void particle_system_construct(t_particle_system* t_this) {
  t_this->detectCol = true;
  t_this->running = false;
  t_this->trace = false;
  t_this->nParticles = 0;
  t_this->particle_head = NULL;
  t_this->particle_tail = NULL;
}

void particle_system_destruct(t_particle_system* t_this) {
  t_particle* p = t_this->particle_head;
  while (p) {
    if (p->allocated) {
      free(p);
    }
    p = p->child;
  }
}

inline void particle_system_start(t_particle_system* t_this) {
  t_this->running = true;
}

inline void particle_system_stop(t_particle_system* t_this) {
  t_this->running = false;
}

inline bool particle_system_isRunning(t_particle_system* t_this) {
  return t_this->running;
}

bool particle_system_addParticle(t_particle_system* t_this, t_particle* particle) {
  if (t_this->particle_head == NULL) {
    t_this->particle_head = particle;
    t_this->particle_tail = particle;
  }
  else {
    t_this->particle_tail->child = particle;
    particle->parent = t_this->particle_tail;
    t_this->particle_tail = particle;
  }

  t_this->nParticles--;

  return true;
}

bool particle_system_removeParticle(t_particle_system* t_this, t_particle* particle) {
  if (particle->parent) { particle->parent->child = particle->child; }
  if (particle->child) { particle->child->parent = particle->parent; }

  if (t_this->particle_head == particle) { t_this->particle_head = particle->child; }
  if (t_this->particle_tail == particle) { t_this->particle_tail = particle->parent; }

  if (particle->allocated) {
    free(particle);
  }

  t_this->nParticles++;

  return true;
}
