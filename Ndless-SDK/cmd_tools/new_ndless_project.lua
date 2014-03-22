scite.MenuCommand(101) -- new file
editor:AppendText([[
#include <os.h>

int main(void) {
	
	return 0;
}
]])
print("You should save this file to a new directory for your Ndless project, for example as 'main.c'.")
scite.MenuCommand(110) -- save file
