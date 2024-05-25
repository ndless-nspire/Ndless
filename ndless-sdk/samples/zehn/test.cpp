#include <iostream>

#include <libndls.h>

using namespace std;

// Test global object construcion and order.
// This should work both with -fuse-cxa-atexit (the default)
// and -fno-use-cxa-atexit.
template <int i>
class Test
{
public:
	Test() { cout << "Test(" << i << ")" << endl; }
	~Test() {
		cout << "~Test(" << i << ")" << endl;
		if (i == 1000) // Should be last
			wait_key_pressed();
	}

	void doSomething() { cout << "Doing something!" << endl; }
};

static __attribute__ ((init_priority (1000))) Test<1000> t1000;
static __attribute__ ((init_priority (1001))) Test<1001> t1001;
// No init_priority is means higher than any init_priority
static Test<1024> test;

int main()
{
	test.doSomething();

	try {
		throw "This is an exception!";
	}
	catch(const char* c)
	{
		cout << "Caught '" << c << "'!" << endl;
	}
	catch(...)
	{
		cerr << "Caught something weird :-(" << endl;
		return 1;
	}

	cout << "Successful! Now press any key to exit." << endl;
	wait_key_pressed();

	return 1;
}
