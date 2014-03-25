/****************************************************************************
 * Definitions
 *
 * The contents of this file are subject to the Mozilla Public
 * License Version 1.1 (the "License"); you may not use this file
 * except in compliance with the License. You may obtain a copy of
 * the License at http://www.mozilla.org/MPL/
 *
 * Software distributed under the License is distributed on an "AS
 * IS" basis, WITHOUT WARRANTY OF ANY KIND, either express or
 * implied. See the License for the specific language governing
 * rights and limitations under the License.
 *
 * The Original Code is Ndless code.
 *
 * The Initial Developer of the Original Code is Olivier ARMAND
 * <olivier.calc@gmail.com>.
 * Portions created by the Initial Developer are Copyright (C) 2012
 * the Initial Developer. All Rights Reserved.
 *
 * Contributor(s): 
 ****************************************************************************/

#ifndef _NDLESS_TESTS_H_
#define _NDLESS_TESTS_H_

#ifdef __cplusplus
extern "C" {
#endif

#define assert(tstname, expr, format, ...) \
	do { \
		char sbuf[100]; \
		if (!(expr)) { \
			sprintf(sbuf, "%s(" format ")", __func__, __VA_ARGS__); \
			error(tstname, sbuf); \
		} else { \
		printf("[passed] [%s]\n", tstname);	\
		} \
	} while(0)

/* assert.c */

extern unsigned errcount;

void error(const char *tstname, const char *errmsg);
void assertUIntEquals(const char *tstname, unsigned expected, unsigned actual);
void assertIntEquals(const char *tstname, int expected, int actual);
__attribute__((unused)) void assertUIntGreater(const char *tstname, unsigned expected, unsigned actual);
void assertUIntLower(const char *tstname, unsigned expected, unsigned actual);
void assertZero(const char *tstname, unsigned actual);
void assertNonZero(const char *tstname, unsigned actual);
void assertTrue(const char *tstname, BOOL actual);
void assertFalse(const char *tstname, BOOL actual);
void assertCharEquals(const char *tstname, char expected, char actual);
void assertStrEquals(const char *tstname, const char *expected, const char *actual);
void assertNotNull(const char *tstname, void *actual);
void assertNull(const char *tstname, void *actual);

#define assertRuns(tstname, dummy) \
	(void)dummy; \
	printf("[passed] [%s]\n", tstname);

#ifdef __cplusplus
}
#endif

#endif /* _NDLESS_TESTS_H_ */
