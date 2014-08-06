/**
 * @file queue.h
 * @author  Julian Mackeben aka compu <compujuckel@googlemail.com>
 * @version 3.1
 *
 * @section LICENSE
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
 * MA 02110-1301  USA
 *
 * @section DESCRIPTION
 *
 * Queue header
 */

#ifndef QUEUE_H
#define QUEUE_H

#include <os.h>

#define QUEUE_SIZE 500

/** queue structure */
typedef struct
{
	char data[QUEUE_SIZE + 1];
	int start;
	int end;
	int count;
} queue;

/** Initialize queue.
	@param q Queue to initialize
*/
void queue_init(queue* q);

/** Push value to the end of the queue.
	@param q Queue
	@param val Value to push
*/
void queue_put(queue* q, char val);

/** Get value from the end of the queue.
	@param q Queue
	@return the value
*/
char queue_get_top(queue* q);

/** Get value from the beginning of the queue.
	@param q Queue
	@return the value
*/
char queue_get(queue* q);

/** Check if the queue is empty.
	@param q Queue
	@return TRUE if empty
*/
BOOL queue_empty(queue* q);

#endif