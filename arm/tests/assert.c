/****************************************************************************
 * Assertion subroutines.
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

#include <os.h>
#include "ndless_tests.h"

unsigned errcount = 0;

void error(const char *tstname, const char *errmsg) {
	printf("[FAILED] [%s]: %s\n", tstname, errmsg);
	errcount++;
}

void assertUIntEquals(const char *tstname, unsigned expected, unsigned actual) {
	assert(tstname, expected == actual, "%x, %x", expected, actual);
}

void assertIntEquals(const char *tstname, int expected, int actual) {
	assert(tstname, expected == actual, "%i, %i", expected, actual);
}

__attribute__((unused)) void assertUIntGreater(const char *tstname, unsigned expected, unsigned actual) {
	assert(tstname, expected < actual, "%x, %x", expected, actual);
}

void assertUIntLower(const char *tstname, unsigned expected, unsigned actual) {
	assert(tstname, expected > actual, "%x, %x", expected, actual);
}

void assertZero(const char *tstname, unsigned actual) {
	assert(tstname, !actual, "%x", actual);
}

void assertNonZero(const char *tstname, unsigned actual) {
	assert(tstname, actual, "%x", actual);
}

void assertTrue(const char *tstname, BOOL actual) {
	assert(tstname, actual, "%s", actual ? "TRUE" : "FALSE");
}

void assertFalse(const char *tstname, BOOL actual) {
	assert(tstname, !actual, "%s", actual ? "TRUE" : "FALSE");
}

void assertCharEquals(const char *tstname, char expected, char actual) {
	assert(tstname, expected == actual, "\"%c\", \"%c\"", expected, actual);
}

void assertStrEquals(const char *tstname, const char *expected, const char *actual) {
	assert(tstname, !strcmp(expected, actual), "\"%s\", \"%s\"", expected, actual);
}

void assertNotNull(const char *tstname, void *actual) {
	assert(tstname, actual, "%p", actual);
}

void assertNull(const char *tstname, void *actual) {
	assert(tstname, !actual, "%p", actual);
}
