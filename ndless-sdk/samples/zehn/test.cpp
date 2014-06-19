#include <cstdio>

class Test
{
public:
	Test() { puts("Test();"); }
	~Test() { puts("~Test();"); }

	void doSomething() { puts("Did something!"); }
};

//Test global variables + initialization
static Test test;

int main()
{
	test.doSomething();

	try {
		throw "Hi!";
	}
	catch(const char* c)
	{
		printf("Caught '%s'!\n", c);
		return 0;
	}
	catch(...)
	{
		puts("Caught something weird :-(");
		return 1;
	}
	puts("I'm running!\n");

	return 1;
}
