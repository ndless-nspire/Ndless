#include <os.h>
#include <libndls.h>

int main(void) {
	const char * title = "Title";
	const char * subtitle = "Sub titile"; 
	const char * msg1 = "Element 1";
	const char * msg2 = "Element 2";
	char * defaultvalue = "default value";
	char * value;
	int len;

	if ((len = show_msg_user_input(title, msg1, defaultvalue, &value)) == -1) return 0;
	printf("%s (%d)\n", value, len);
	show_msgbox(title, value); // y u no work
	free(value);
		 
	int value1 = 42;
	int value2 = 1337;
	char popup1_result[256];
	char popup2_result[256];
	if (show_1numeric_input(title, subtitle, msg1, &value1, -42, 9001) != 1) return 0;
	sprintf(popup1_result, "%s:%d", msg1, value1);
	show_msgbox(title, popup1_result);
	show_msgbox_2b(title, "Text", "Button 1", "Button 2");
	show_msgbox_3b(title, "Text", "Button 1", "Button 2", "Button 3");
	if (show_2numeric_input(title, subtitle, msg1, &value1, -42, 9001, msg2, &value2, -42, 9001) != 1) return 0;
	sprintf(popup2_result, "%s:%d\n%s:%d", msg1, value1, msg2, value2);
	show_msgbox(title, popup2_result);

	show_msgbox("Congratulation", "Everything went better than expected!");
	return 0;
}
