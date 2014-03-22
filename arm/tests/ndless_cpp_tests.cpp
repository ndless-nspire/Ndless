/****************************************************************************
 * C++ tests
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
 * The Initial Developer of the Original Code is tangrs.
 * Portions created by the Initial Developer are Copyright (C) 2013
 * the Initial Developer. All Rights Reserved.
 *
 * Contributor(s): Olivier ARMAND <olivier.calc@gmail.com>.
 ****************************************************************************/

#include <os.h>
#include "ndless_tests.h"

class test_class {
	public:
	test_class(int *call_counter) {
		(*call_counter)++;
	}
	int class_method(const char **call_marker) {
		*call_marker = "method1";
		return 1;
	}
};

class test_class2 : test_class {
	public:
	test_class2(int *call_counter) : test_class(call_counter) {
		(*call_counter)++;
	}
	int class_method(const char **call_marker) {
		*call_marker = "method2";
		return 2;
	}
};

int main(int argc, char *argv[]) {
	assertIntEquals("argc", 1, argc);
	assertStrEquals("argv0", "ndless_cpp_tests.tns", strrchr(argv[0], '/') + 1);
	
	const char *call_marker;
	int call_counter = 0;
	test_class *obj1 = new test_class(&call_counter);
	assertIntEquals("constructor1", 1, call_counter);
	call_counter = 0;
	test_class2 *obj2 = new test_class2(&call_counter);
	assertIntEquals("constructor1", 2, call_counter);
	assertIntEquals("method1_return", 1, obj1->class_method(&call_marker));
	assertStrEquals("method1", "method1", call_marker);
	assertIntEquals("method2_return", 2, obj2->class_method(&call_marker));
	assertStrEquals("method2", "method2", call_marker);
	delete obj1;
	delete obj2;
	return 0;
}
