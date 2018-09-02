/****************************************************************************
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
 * The Initial Developer of the Original Code is hoffa
 * Portions created by the Initial Developer are Copyright (C) 2013
 * the Initial Developer. All Rights Reserved.
 *
 * Contributor(s): 
 ****************************************************************************/

#include <os.h>

int enable_relative_paths(char **argv) {
    char buf[256], *p;
    buf[255] = 0;
    strncpy(buf, argv[0], sizeof(buf)-1);
    if (!((p = strrchr(buf, '/'))))
        return -1;
    *p = '\0';
    return NU_Set_Current_Dir(buf) ? -1 : 0;
}
