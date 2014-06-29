#include <cstdint>

typedef void (*DispStr)(const char *, int *, int);

int main()
{
	DispStr disp_str = reinterpret_cast<DispStr>(0x100cba54);
	int x = 0;
	disp_str("Ndless would be installed right now", &x, 0);	

	for (uint32_t i = 0; i < 100000000; i++);
}
