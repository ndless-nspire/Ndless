#include <keys.h>
#include <libndls.h>

//isKeyPressed is defined as a macro for backwards compatibility
#undef isKeyPressed
BOOL isKeyPressed(const t_key *key)
{
	if(is_touchpad && key->tpad_arrow != TPAD_ARROW_NONE)
		return touchpad_arrow_pressed(key->tpad_arrow);
	
	return !is_classic ^ ((is_touchpad ? !((*(volatile short*)(0x900E0000 + key->tpad_row)) & key->tpad_col) : !((*(volatile short*)(0x900E0000 + key->row)) & key->col)));
}
