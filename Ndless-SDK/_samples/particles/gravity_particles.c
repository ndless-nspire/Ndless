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
#include "gravity_particles.h"

void gravity_particles_construct(t_gravity_particles* t_this, float gravity, int accelerationMultiplier) {
  particle_system_construct(&(t_this->particleSystem));
  t_this->gravitationalConstant = gravity;
  t_this->accelerationMultiplier = accelerationMultiplier;
}

inline void gravity_particles_destruct(t_gravity_particles* t_this) {
  particle_system_destruct(&(t_this->particleSystem));
}

t_particle* gravity_particles_merge(t_gravity_particles* t_this, t_particle* i, t_particle* j) {
  float newX, newY, newZ;
  t_vector v, vTmp1, vTmp2;
  t_particle* k;

  newX = (i->location.x + j->location.x) / 2.f;
  newY = (i->location.y + j->location.y) / 2.f;
  newZ = (i->location.z + j->location.z) / 2.f;

  // Conservation of momentum in inelastic collision:
  // final velocity = (m1 * v1 + m2 * v2)/(m1 + m2)
  vTmp1 = vector_mul(&(i->velocity), i->mass);
  vTmp2 = vector_mul(&(j->velocity), j->mass);
  v = vector_add(&vTmp1, &vTmp2);
  v = vector_div(&v, (i->mass + j->mass));

  k = particle_construct3(&((t_vector){newX, newY, newZ}), &v, i->mass + j->mass, j->size, j->color);

  particle_draw(i, WHITE);
  particle_draw(j, WHITE);

  particle_system_removeParticle(&(t_this->particleSystem), i);
  particle_system_removeParticle(&(t_this->particleSystem), j);
  particle_system_addParticle(&(t_this->particleSystem), k);

  return k;
}

void gravity_particles_draw(t_gravity_particles* t_this) {
  t_rect ri, rj;
  t_particle *pi, *pj, *pNext;
  t_particle_system* particle_system = &(t_this->particleSystem);
  float magnitude, factor;
  t_vector v1, v2, unit;
  t_vector ai, aj;

  if (particle_system->running == false) { return; }

  // check for collisions
  if (particle_system->detectCol) {
    pi = particle_system->particle_head;
    while (pi) {
      ri.x = pi->xScreen;
      ri.y = pi->yScreen;
      ri.w = pi->size;
      ri.h = pi->size;

      pj = particle_system->particle_head;
      while (pj) {
        if (pi != pj) {
          rj.x = pj->xScreen;
          rj.y = pj->yScreen;
          rj.w = pj->size;
          rj.h = pj->size;

          if ( (pi->location.z - pj->location.z < 5)
            && (pi->location.z - pj->location.z > -5)
            && rect_intersect(&ri, &rj)
          )
          {
            pNext = pi->parent;
            (void) gravity_particles_merge(t_this, pi, pj);
            pi = pNext;
            pj = NULL;
            continue;
          }
        }
        pj = pj->child;
      }

      if (pi != NULL) {
        pi = pi->child;
      }
    }
  }

  // Sort Z
  //particle_system_sort(particle_system->particles, particle_system->tmp_particles, particle_system->maxParticles);

  pi = particle_system->particle_head;
  while (pi) {
    vector_construct(&ai);
    pj = particle_system->particle_head;
    while (pj) {
      vector_construct(&aj);

      if (pi != pj) {
        v1 = particle_midLocation(pj);
        v2 = particle_midLocation(pi);
        unit = vector_sub(&v1, &v2);
        magnitude = sqrtf((unit.x * unit.x) + (unit.y * unit.y) + (unit.z * unit.z));
        factor = (t_this->gravitationalConstant * ((pi->mass * pj->mass) / (magnitude * magnitude * magnitude))) / pi->mass;
        unit = vector_mul(&unit, factor);
        aj = unit;
        ai = vector_add(&ai, &aj);
      }

      pj = pj->child;
    }

    pi->velocity = vector_add(&(pi->velocity), &ai);
    pi->acceleration = ai;

    if (!particle_system->trace) {
      particle_draw(pi, WHITE);
    }

    particle_update(pi);

    if ( (pi->location.x > 5000.f)
      || (pi->location.x < -5000.f)
      || (pi->location.y > 5000.f)
      || (pi->location.y < -5000.f)
      || (pi->location.z > 5000.f)
      || (pi->location.z < -5000.f)
    )
    {
      pNext = pi->child;
      particle_system_removeParticle(particle_system, pi);
      pi = pNext;
      continue;
    }

    particle_draw(pi, pi->color);
    pi = pi->child;
  }
}

void add_particle(t_gravity_particles* gravity_particles) {
  t_particle* p;
  float x, y, vel1, vel2;
  int mass, color;
  t_vector pL, pV;

  color = ~(gravity_particles->particleSystem.nParticles) & 0x0F;
  if (color == WHITE) color = BLACK;

  mass = rand() % 7;
  switch (mass) {
    case 0: mass = 5; break;
    case 1: mass = 10; break;
    case 2: mass = 100; break;
    case 3: mass = 200; break;
    case 4: mass = 500; break;
    case 5: mass = 1000; break;
    default: mass = 1;
  }

  x = -1000 + (rand() % 2000);
  y = -1000 + (rand() % 2000);

  vel1 = (rand() % 25) / 10.f;
  vel2 = (rand() % 25) / 10.f;
  if (x > 0) vel1 = -vel1;
  if (y > 0) vel2 = -vel2;

  pL.x = x; pL.y = y; pL.z = 1.f;
  pV.x = vel1; pV.y = vel2; pV.z = 0.f;
  p = particle_construct3(&pL, &pV, mass, 4, color);
  (void) particle_system_addParticle(&(gravity_particles->particleSystem), p);

  /*pL.x = -pL.x;
  pV.x = -pV.x;
  p = particle_construct3(&pL, &pV, mass, 4, ~color & 0x0F);
  (void) particle_system_addParticle(&(gravity_particles->particleSystem), p);*/
}

void remove_particle(t_gravity_particles* gravity_particles) {
  t_particle* p = gravity_particles->particleSystem.particle_head;
  if (p == NULL) { return; }

  particle_draw(p, WHITE);
  particle_system_removeParticle(&(gravity_particles->particleSystem), p);
}
