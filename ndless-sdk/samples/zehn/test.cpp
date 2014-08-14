#include <iostream>

#include <libndls.h>

using namespace std;

class Test
{
public:
	Test() { cout << "Test();" << endl; }
	~Test() { cout << "~Test();" << endl; }

	void doSomething() { cout << "Doing something!" << endl; }
};

//Test global variables + initialization
static Test test;

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

	cout << "Successfull! Now press any key to exit." << endl;
	wait_key_pressed();

	return 1;
}
