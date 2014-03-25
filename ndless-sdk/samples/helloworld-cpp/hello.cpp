#include <os.h>

class test_class {
	public:
	test_class() {
		printf("hel-");
	}
	int class_method() {
		printf("not me");
		return 1;
	}
};

class test_class2 : test_class {
	public:
	test_class2() {
		printf("lo\n");
	}
	int class_method() {
		printf("world!\n");
		return 1;
	}
};

int main(void) {
	test_class2 *obj = new test_class2();
	obj->class_method();
	return 0;
}
