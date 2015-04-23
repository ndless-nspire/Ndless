/*****************************************************************************
 * @(#) Ndless - Particle System Demo (Vector class)
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

#ifndef _VECTOR_H_
#define _VECTOR_H_

#include "utils.h"

typedef struct {
  float x, y, z;
} t_vector;

extern void vector_construct(t_vector* t_this);
extern void vector_construct2(t_vector* t_this, float x, float y, float z);
extern void vector_construct3(t_vector* t_this, const t_vector* vector);
extern void vector_zero(t_vector* t_this);
extern void vector_xAxis(t_vector* t_this);
extern void vector_yAxis(t_vector* t_this);
extern void vector_zAxis(t_vector* t_this);
extern t_vector vector_add(const t_vector* vector1, const t_vector* vector2);
extern t_vector vector_sub(const t_vector* vector1, const t_vector* vector2);
extern t_vector vector_negate(const t_vector* vector);
extern t_vector vector_mul(const t_vector* vector, float val);
extern t_vector vector_div(const t_vector* vector, float val);
extern bool vector_compare(const t_vector* vector1, const t_vector* vector2);

#endif
