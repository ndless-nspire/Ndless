//build@ gcc -shared -o spawner-ex.dll -I..\..\lua\include win32-spawner-ex.c scite.la 
#include <windows.h>
#include <assert.h>
#include <stdio.h>
#include <process.h>
#include <malloc.h>
#include <stdlib.h>
#include <string.h>
#include <io.h>
#include <fcntl.h>
#include <ctype.h>
#include <lua.h>
#include <lauxlib.h>
#include <lualib.h>

static char buffer[16384]; // buffer for reading from a process
static char linebuf[512];  // line buffer
static char outbuf[16384]; // buffer for constructing messages to SciTE
static int fulllines = 1;
static HWND hSciTE;
static HWND hSelf;
static HINSTANCE hInstance;

// Director interface to other SciTE instances.
static int SendToHandle(HWND hwnd, const char *Message)
{
  COPYDATASTRUCT cds;
  int size = strlen(Message);
  cds.dwData = 0;	
  cds.lpData = (void *)Message;
  cds.cbData = size;
  return SendMessage(hwnd, WM_COPYDATA,(WPARAM)NULL,(LPARAM)&cds);
}

static int size_of_array(HWND* results)
{
    int idx = 0;	
    // find our place in the output array	
    for (idx = 0; results[idx] != NULL; idx++) ;	
    return idx;
}

BOOL CALLBACK EnumWindowsProc(HWND  hwnd, LPARAM  lParam)
{
    HWND* results = (HWND*)lParam;
    int idx = size_of_array(results);	
    char buff[256];
    GetClassName(hwnd,buff,sizeof(buff));	
    if (strcmp(buff,"DirectorExtension") == 0) {
        if (GetWindowLongPtr(hwnd,GWLP_USERDATA) == hSciTE) {
            hSelf = hwnd;     
        } else {
            results[idx] = hwnd;
            results[idx+1] = NULL;
        } 
    }
    return TRUE;
}

// 0 refers to current instance, 1,2...etc to other instances.
static int do_perform(lua_State* L)
{
    char buff[128];
    const char* cmd = lua_tostring(L,1);
    int this_instance = lua_tointeger(L,2);
    HWND results[50];
    int nmsg;
    results[0] = 0;
    EnumWindows(EnumWindowsProc,(long)results);
    nmsg = size_of_array(results);	
    if (this_instance > nmsg) {
        lua_pushnil(L);
        lua_pushliteral(L,"no other instance available");
        return 2;
    } else {
        int res = SendToHandle(this_instance ? results[this_instance-1] : hSelf,cmd);
        lua_pushinteger(L,res);
        return 1;
    }
}

static int do_foreground(lua_State* L)
{
    SetForegroundWindow(hSciTE);
    return 0;
}

static int do_verbose(lua_State* L)
{
    return 0;
}

static int do_fulllines(lua_State* L)
{
    //fulllines = luaL_checkboolean(L,1);
    return 0;
}

const UINT STE_WM_ONEXECUTE = 2001;

static void exec_lua(lua_State* L, const char* fun, const char* args)
{
    lua_getglobal(L,fun);
    lua_pushstring(L,args);
    if (lua_pcall(L,1,0,0) != 0) {
        lua_getglobal(L,"print");
        lua_pcall(L,1,0,0);
    }
}


LRESULT PASCAL WndProc(HWND hwnd, UINT uMsg, WPARAM wParam, LPARAM lParam)
{
    WNDPROC lpPrevWndProc;
    if (uMsg == STE_WM_ONEXECUTE) {
        lua_State *L = (lua_State *)wParam;
        char* args = (char *)lParam;
        char* fun, *arg;
        char* ptr = strchr(args,' ');
        *ptr = '\0';
        fun = args;
        arg = ptr+1;
        exec_lua(L,fun,arg);
        free(args);
        return 0;
    }

    lpPrevWndProc = (WNDPROC)GetWindowLongPtr(hwnd, GWLP_USERDATA);
    if (lpPrevWndProc)
        return CallWindowProc(lpPrevWndProc, hwnd, uMsg, wParam, lParam);

    return DefWindowProc(hwnd, uMsg, wParam, lParam);
}

static HWND hwndDispatcher;

void create_thread_window(void)
{
    LONG_PTR subclassedProc;
    hwndDispatcher = CreateWindow(
        "STATIC", "SciTE_Spawner_Dispatcher",
        0, 0, 0, 0, 0, 0, 0, GetModuleHandle(NULL), 0
    );
    subclassedProc = SetWindowLongPtr(hwndDispatcher, GWLP_WNDPROC, (LONG_PTR)WndProc);
    SetWindowLongPtr(hwndDispatcher, GWLP_USERDATA, subclassedProc);
}

#define SPAWNER "SPAWNER"

typedef struct {
    const char* command_line;	
    const char* output;
    const char* result;
    lua_State* L;
    BOOL peeking;
    BOOL running;
    HANDLE hProcess;
    PROCESS_INFORMATION pi;
    HANDLE hWriteSubProcess;
    HANDLE hPipeRead;
    HANDLE hPipeWrite;
    FILE* inf;
} Spawner;


static BOOL start_process(Spawner* p)
{
    const char* prog = p->command_line;
    SECURITY_ATTRIBUTES sa = {sizeof(SECURITY_ATTRIBUTES), 0, 0};
    SECURITY_DESCRIPTOR sd;
    STARTUPINFO si = {
                 sizeof(STARTUPINFO), 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
             };	

    HANDLE hRead2;
    HANDLE hProcess = GetCurrentProcess();
    sa.bInheritHandle = TRUE;
    sa.lpSecurityDescriptor = NULL;
    InitializeSecurityDescriptor(&sd, SECURITY_DESCRIPTOR_REVISION);
    SetSecurityDescriptorDacl(&sd, TRUE, NULL, FALSE);
    sa.nLength = sizeof(SECURITY_ATTRIBUTES);
    sa.lpSecurityDescriptor = &sd;

    // Create pipe for output redirection
    // read handle, write handle, security attributes,  number of bytes reserved for pipe - 0 default
    CreatePipe(&p->hPipeRead, &p->hPipeWrite, &sa, 0);
    
    // Create pipe for input redirection. In this code, you do not
    // redirect the output of the child process, but you need a handle
    // to set the hStdInput field in the STARTUP_INFO struct. For safety,
    // you should not set the handles to an invalid handle.

    hRead2 = NULL;
    // read handle, write handle, security attributes,  number of bytes reserved for pipe - 0 default
    CreatePipe(&hRead2, &p->hWriteSubProcess, &sa, 0);
    
    SetHandleInformation(p->hPipeRead, HANDLE_FLAG_INHERIT, 0);
    SetHandleInformation(p->hWriteSubProcess, HANDLE_FLAG_INHERIT, 0);

    si.dwFlags = STARTF_USESHOWWINDOW | STARTF_USESTDHANDLES;
    si.wShowWindow = SW_HIDE;
    si.hStdInput = hRead2;
    si.hStdOutput = p->hPipeWrite;
    si.hStdError = p->hPipeWrite;

    p->running = CreateProcess(
              NULL,
              (char*)prog,
              NULL, NULL,
              TRUE, CREATE_NEW_PROCESS_GROUP,
              NULL,
              NULL, // start directory
              &si, &p->pi);
              
    CloseHandle(p->pi.hThread);
    CloseHandle(hRead2);
    CloseHandle(p->hPipeWrite);
    return p->running;
}

static void send_to_scite(lua_State* L, const char* fun, const char* args)
{
    char* command = (char*)malloc(strlen(fun)+strlen(args)+1+1);
    sprintf(command,"%s %s",fun,args);
    SendMessage(hwndDispatcher, STE_WM_ONEXECUTE, (WPARAM)L, (LPARAM)command);
}

static void monitor_process(Spawner* p)
{
    DWORD exitcode;
    if (WAIT_OBJECT_0 == WaitForSingleObject(p->pi.hProcess, INFINITE)) {
        GetExitCodeProcess(p->pi.hProcess, &exitcode);	
        CloseHandle(p->pi.hProcess);
        if (p->result) {
            sprintf(buffer,"%d",exitcode);
            send_to_scite(p->L,p->result,buffer);
        }	
    }
}


static void run_process(Spawner* p)
{
    DWORD bytesRead = 0;
    BOOL bTest;
    DWORD exitcode;	
    //* FILE* reader = fdopen(p->hPipeRead,"r");
    Sleep(50);
    
    while (p->running) {
        *buffer = '\0';
        while (1) {
            bTest = ReadFile(p->hPipeRead, linebuf,
                           sizeof(linebuf), &bytesRead, NULL);
            if (bTest && bytesRead) {
                linebuf[bytesRead] = '\0';
                if (fulllines && linebuf[bytesRead-1] == '\n') {
                    strcat(buffer,linebuf);
                    break;
                } else {
                    strcat(buffer,linebuf);
                }				
            } else {
                p->running = FALSE;
                break;
            }
        }
        send_to_scite(p->L,p->output,buffer);
    }
    GetExitCodeProcess(p->pi.hProcess, &exitcode);	
    CloseHandle(p->pi.hProcess);
    if (p->result) {
        sprintf(buffer,"%d",exitcode);
        send_to_scite(p->L,p->result,buffer);
    }
    //* fclose(reader);
    CloseHandle(p->hPipeRead);
}


static int new_spawner(lua_State* L)
{
    Spawner* spp = (Spawner*)lua_newuserdata(L,sizeof(Spawner));
    memset(spp,0,sizeof(Spawner));
    spp->command_line = luaL_checkstring(L,1);
    spp->L = L;
    luaL_getmetatable(L,SPAWNER);
    lua_setmetatable(L,-2);
    return 1;
}

static int spawner_set_output(lua_State* L)
{
    Spawner* spp = (Spawner*)lua_touserdata(L,1);
    spp->output = luaL_checkstring(L,2);
    return 0;
}

static int spawner_set_result(lua_State* L)
{
    Spawner* spp = (Spawner*)lua_touserdata(L,1);
    spp->result = luaL_checkstring(L,2);
    return 0;
}

static int spawner_use_shell(lua_State* L)
{
    Spawner* spp = (Spawner*)lua_touserdata(L,1);
    char* new_command;
    const char* comspec = getenv("COMSPEC");
    if (! comspec) comspec = "CMD.EXE";
    new_command = (char*)malloc(strlen(spp->command_line)+20);
    sprintf(new_command,"%s /c %s",comspec,spp->command_line);
    spp->command_line = new_command;
    return 0;
}

static int spawner_write(lua_State* L)
{
    Spawner* spp = (Spawner*)lua_touserdata(L,1);	
    const char* buff = luaL_checkstring(L,2);
    DWORD bytesWrote;
    DWORD nReaded = strlen(buff);
    WriteFile(spp->hWriteSubProcess,buff,nReaded, &bytesWrote, NULL);		
    lua_pushboolean(L,nReaded == bytesWrote);
    return 1;
}

static int spawner_read(lua_State* L)
{
    Spawner* spp = (Spawner*)lua_touserdata(L,1);
    char* res = fgets(buffer,sizeof(buffer),spp->inf);
    if (res) {
        lua_pushstring(L,buffer);
        return 1;
    } else {
        lua_pushnil(L);
    }
    return 1;
}

static void newfile_from_handle (lua_State *L, HANDLE handle, const char* mode);

static int spawner_run(lua_State* L)
{
    Spawner* spp = (Spawner*)lua_touserdata(L,1);
    if (! start_process(spp)) {
        lua_pushboolean(L,FALSE);
        return 1;
    }
    //_beginthread(monitor_process,0,spp);
    if (spp->output != NULL) {
        _beginthread(run_process, 1024 * 1024,spp);
    } else {
        int fd;
        fd = _open_osfhandle((long)spp->hPipeRead, _O_BINARY);
        spp->inf = _fdopen(fd,"r");
        //Sleep(50);
    }
    lua_pushboolean(L,TRUE);
    return 1;
}

static Spawner* start_popen(lua_State* L)
{
    Spawner* spp = (Spawner*)malloc(sizeof(Spawner));
    const char* comspec = getenv("COMSPEC");
    char* new_command;

    memset(spp,0,sizeof(Spawner));
    spp->command_line = luaL_checkstring(L,1);
    if (! comspec) comspec = "CMD.EXE";
    new_command = (char*)malloc(strlen(spp->command_line) + strlen(comspec) + 20);
    sprintf(new_command,"%s /c %s",comspec,spp->command_line);
    spp->command_line = new_command;
    if (! start_process(spp)) {
        lua_pushboolean(L,FALSE);
        return NULL;
    }
    //_beginthread(monitor_process,0,spp);
    return spp;
}

static int do_popen(lua_State* L)
{
    Spawner* spp = start_popen(L);
    newfile_from_handle(L,spp->hPipeRead,"rt");
    return 1;
}

static int do_popen2(lua_State* L)
{
    Spawner* spp = start_popen(L);
    newfile_from_handle(L,spp->hWriteSubProcess,"wt");
    newfile_from_handle(L,spp->hPipeRead,"rt");
    return 2;
}

static int spawner_kill(lua_State* L)
{
    Spawner* spp = (Spawner*)lua_touserdata(L,1);
    TerminateProcess(spp->pi.hProcess, 2);
    spp->pi.hProcess = NULL;
    return 0;
}


/////// stuff from liolib

#define PIPE_FILEHANDLE "PIPE_FILE*"

// based on liolib.c
static void newfile_from_handle (lua_State *L, HANDLE handle, const char* mode)
{
  FILE **pf = (FILE **)lua_newuserdata(L, sizeof(FILE *));
  int fd;
  *pf = NULL;
  luaL_getmetatable(L, PIPE_FILEHANDLE);
  lua_setmetatable(L, -2);
  fd = _open_osfhandle((long)handle, _O_TEXT);
  *pf = _fdopen(fd,mode);
  // leaves the userdata on the lua stack!
}

static int pushresult (lua_State *L, int i, const char *filename) {
  int en = errno;  /* calls to Lua API may change this value */
  if (i) {
    lua_pushboolean(L, 1);
    return 1;
  }
  else {
    lua_pushnil(L);
    if (filename)
      lua_pushfstring(L, "%s: %s", filename, strerror(en));
    else
      lua_pushfstring(L, "%s", strerror(en));
    lua_pushinteger(L, en);
    return 3;
  }
}

static FILE *tofile (lua_State *L) {
  FILE **f = (FILE **)luaL_checkudata(L, 1, PIPE_FILEHANDLE);
  if (*f == NULL)
    luaL_error(L, "attempt to use a closed file");
  return *f;
}

static int f_close (lua_State *L) {
  FILE *f = tofile(L);
  fclose(f);
  return 0;
}

static int read_line (lua_State *L, FILE *f);

static int io_readline (lua_State *L) {
  FILE *f = *(FILE **)lua_touserdata(L, lua_upvalueindex(1));
  int sucess;
  if (f == NULL)  /* file is already closed? */
    luaL_error(L, "file is already closed");
  sucess = read_line(L, f);
  if (ferror(f))
    return luaL_error(L, "%s", strerror(errno));
  if (sucess) return 1;
  else {  /* EOF */
    return 0;
  }
}

static int f_lines (lua_State *L) {
  tofile(L);  /* check that it's a valid file handle */
  lua_pushvalue(L, 1);
  lua_pushcclosure(L, io_readline, 1);
  return 1;
}

static int read_number (lua_State *L, FILE *f) {
  lua_Number d;
  if (fscanf(f, LUA_NUMBER_SCAN, &d) == 1) {
    lua_pushnumber(L, d);
    return 1;
  }
  else return 0;  /* read fails */
}


static int test_eof (lua_State *L, FILE *f) {
  int c = getc(f);
  ungetc(c, f);
  lua_pushlstring(L, NULL, 0);
  return (c != EOF);
}


static int read_line (lua_State *L, FILE *f) {
  luaL_Buffer b;
  luaL_buffinit(L, &b);
  for (;;) {
    size_t l;
    char *p = luaL_prepbuffer(&b);
    if (fgets(p, LUAL_BUFFERSIZE, f) == NULL) {  /* eof? */
      luaL_pushresult(&b);  /* close buffer */
      return (lua_strlen(L, -1) > 0);  /* check whether read something */
    }
    l = strlen(p);
    if (l == 0 || p[l-1] != '\n')
      luaL_addsize(&b, l);
    else {
      luaL_addsize(&b, l - 1);  /* do not include `eol' */
      luaL_pushresult(&b);  /* close buffer */
      return 1;  /* read at least an `eol' */
    }
  }
}


static int read_chars (lua_State *L, FILE *f, size_t n) {
  size_t rlen;  /* how much to read */
  size_t nr;  /* number of chars actually read */
  luaL_Buffer b;
  luaL_buffinit(L, &b);
  rlen = LUAL_BUFFERSIZE;  /* try to read that much each time */
  do {
    char *p = luaL_prepbuffer(&b);
    if (rlen > n) rlen = n;  /* cannot read more than asked */
    nr = fread(p, sizeof(char), rlen, f);
    luaL_addsize(&b, nr);
    n -= nr;  /* still have to read `n' chars */
  } while (n > 0 && nr == rlen);  /* until end of count or eof */
  luaL_pushresult(&b);  /* close buffer */
  return (n == 0 || lua_strlen(L, -1) > 0);
}


static int f_read (lua_State *L) {
  FILE *f = tofile(L);
  int nargs = lua_gettop(L) - 1;
  int success;
  int n;
  clearerr(f);
  if (nargs == 0) {  /* no arguments? */
    success = read_line(L, f);
    n = 2+1;  /* to return 1 result */
  }
  else {  /* ensure stack space for all results and for auxlib's buffer */
    luaL_checkstack(L, nargs+LUA_MINSTACK, "too many arguments");
    success = 1;
    for (n = 2; nargs-- && success; n++) {
      if (lua_type(L, n) == LUA_TNUMBER) {
        size_t l = (size_t)lua_tointeger(L, n);
        success = (l == 0) ? test_eof(L, f) : read_chars(L, f, l);
      }
      else {
        const char *p = lua_tostring(L, n);
        luaL_argcheck(L, p && p[0] == '*', n, "invalid option");
        switch (p[1]) {
          case 'n':  /* number */
            success = read_number(L, f);
            break;
          case 'l':  /* line */
            success = read_line(L, f);
            break;
          case 'a':  /* file */
            read_chars(L, f, ~((size_t)0));  /* read MAX_SIZE_T chars */
            success = 1; /* always success */
            break;
          default:
            return luaL_argerror(L, n, "invalid format");
        }
      }
    }
  }
  if (ferror(f))
    return pushresult(L, 0, NULL);
  if (!success) {
    lua_pop(L, 1);  /* remove last result */
    lua_pushnil(L);  /* push nil instead */
  }
  return n - 2;
}


static int f_write (lua_State *L)
{
  FILE *f = tofile(L);
  int nargs = lua_gettop(L) - 1;
  int status = 1;
  int arg = 2;
  for (; nargs--; arg++) {
    if (lua_type(L, 2) == LUA_TNUMBER) {
      /* optimization: could be done exactly as for strings */
      status = status &&
          fprintf(f, LUA_NUMBER_FMT, lua_tonumber(L, arg)) > 0;
    }
    else {
      size_t l;
      const char *s = luaL_checklstring(L, arg, &l);
      status = status && (fwrite(s, sizeof(char), l, f) == l);
    }
  }
  return pushresult(L, status, NULL);
}


static int f_flush (lua_State *L) {
  return pushresult(L, fflush(tofile(L)) == 0, NULL);
}

static const struct luaL_reg spawner[] = {
    {"foreground",do_foreground},
    {"verbose",do_verbose},
    {"fulllines",do_fulllines},
    {"new",new_spawner},
    {"popen",do_popen},
    {"popen2",do_popen2},
    {"perform",do_perform},
    {NULL, NULL}
};

static const struct luaL_reg spawner_methods[] = {
    {"set_output",spawner_set_output},
    {"set_result",spawner_set_result},
    {"use_shell",spawner_use_shell},
    {"write",spawner_write},
    {"read",spawner_read},	
    {"kill",spawner_kill},	
    {"run",spawner_run},	
    {NULL, NULL}
};


static const luaL_Reg file_methods[] = {
  {"close", f_close},
  {"flush", f_flush},
  {"lines", f_lines},
  {"read", f_read},
  {"write", f_write},
  {NULL, NULL}
};

static void createmeta (lua_State *L) {
  luaL_newmetatable(L, PIPE_FILEHANDLE);  /* create metatable for file handles */
  lua_pushvalue(L, -1);  /* push metatable */
  lua_setfield(L, -2, "__index");  /* metatable.__index = metatable */
  luaL_register(L, NULL, file_methods);  /* file methods */
}

__declspec(dllexport)
int luaopen_spawner(lua_State *L)
{
    hSciTE = GetForegroundWindow();
    hInstance = GetWindowLong(hSciTE,GWL_HINSTANCE);
    create_thread_window();
    createmeta(L);

    luaL_openlib (L, "spawner", spawner, 0);
    luaL_newmetatable(L, SPAWNER);  // create metatable for spawner objects
    lua_pushvalue(L, -1);  // push metatable
    lua_setfield(L, -2, "__index");  // metatable.__index = metatable
    luaL_register(L, NULL, spawner_methods); 	
    return 1;	
}
