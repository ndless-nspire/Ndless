// unix-spawner-ex.c
/* An extension for SciTE Lua that provides process management for SciTE scripts.
*  This extension provides a table 'spawner' which contains some very useful
*  functions, popen() and popen2(), for spawning processes and capturing their
*  input. (io.popen() is broken on Windows, and has serious problems on Unix)
*  It provides a spawner object which can be used to capture interactive processes
* Steve Donovan, 2007. 
* Released under the same generous licence as SciTE itself.
*/
#include <pty.h>
#include <unistd.h>
#include <sys/types.h>
#include <stdio.h>
#include <stdlib.h>
#include <errno.h>
#include <string.h>
#include <glob.h>

#include <lua.h>
#include <lauxlib.h>
#include <lualib.h>

#include <gdk/gdk.h>

static int verbose = 0;

static char *quote_strtok(char *str, char str_delim)
{
// a specialized version of strtok() which treats quoted strings specially 
// (used for handling command-line parms)
    static char *tok;
    if(str != NULL) tok = str;
          
    while (*tok && isspace(*tok)) tok++;
    if (*tok == '\0') return NULL;
    
    if (*tok == str_delim) {       
       tok++;            // skip "
       str = tok;
       while (*tok && *tok != str_delim) tok++;        
    } else {
       str = tok;
       while (*tok && ! isspace(*tok)) tok++;
    }
    if (*tok) *tok++ = '\0';  
    return str;
}

#define READ 0
#define WRITE 1

pid_t
popen2(const char *command, int *infp, int *outfp)
{
    int p_stdin[2], p_stdout[2];
    pid_t pid;

    if (pipe(p_stdin) != 0 || pipe(p_stdout) != 0)
        return -1;

    pid = fork();

    if (pid < 0)
        return pid;
    else if (pid == 0)
    {
        close(p_stdin[WRITE]);
        dup2(p_stdin[READ], READ);
        close(p_stdout[READ]);
        dup2(p_stdout[WRITE], WRITE);

        execl("/bin/sh", "sh", "-c", command, NULL);
        perror("execl");
        exit(1);
    }

    // note that it is NB to close the other ends of the pipes!
    if (infp == NULL)
        close(p_stdin[WRITE]);
    else {
        close(p_stdin[READ]);
        *infp = p_stdin[WRITE];
    }

    if (outfp == NULL)
        close(p_stdout[READ]);
    else {
        close(p_stdout[WRITE]);
        *outfp = p_stdout[READ];
    }

    return pid;
}


void msleep(long millisec)
{
    struct timespec tspec;
    tspec.tv_sec = 0;
    tspec.tv_nsec = 1000*1000*millisec;
    nanosleep(&tspec,NULL);
}

typedef struct {
	const char* command_line;	
	const char* output;
	const char* result;
    int pid;
    FILE* child;
    FILE* rdr;
    lua_State* L;
    int child_fd;
    gint gdk_handle;

} Spawner;

int start_process(Spawner* p)
{
    char* argline = strdup(p->command_line);
    char* args[30];
    int i = 0;
    char *arg;
    if (verbose) fprintf(stderr,"'%s'\n",argline);
    arg = quote_strtok(argline,'"');
    if (arg == NULL) return 0;
    while (arg != NULL) {
        args[i++] = arg;
        if (verbose) fprintf(stderr,"-%s\n",arg);
        arg = quote_strtok(NULL,'"');
    }
    args[i] = NULL;
    p->pid = forkpty(&p->child_fd,NULL,NULL,NULL);
    if (p->pid == 0) { // child
        execvp(args[0],args);
        // if we get here, it's an error!
        perror("'unable to spawn process");
        exit(-1);
    } else {
        p->rdr = fdopen(p->child_fd,"r");        
        msleep(200);
        if (verbose) fprintf(stderr,"'listening\n");
        p->child = fdopen(p->child_fd,"w");
    }  
    return 1;
}

static char line[512];

void lua_invoke(lua_State* L, const char* fun, const char* arg)
{
    int res;
    lua_getglobal(L,fun);
    lua_pushstring(L,arg);
    res = lua_pcall(L,1,.0,0);   
    if (res == LUA_ERRRUN) {
        lua_getglobal(L, "print");
        lua_insert(L, -2); // use pushed error message
        lua_pcall(L, 1, 0, 0);
	}    
}

void read_callback(Spawner* p)
{
    int nr = read(p->child_fd,line,sizeof(line));
    if (nr > 0) {
        line[nr] = '\0';
        if (verbose) fprintf(stderr,"'%s'\n",line);
        lua_invoke(p->L,p->output,line);
    } else {        
        gdk_input_remove(p->gdk_handle);
        if (p->result != NULL) {
            char buff[15];
            int res = 0;
            wait(&res);
            sprintf(buff,"%d",res);
            lua_invoke(p->L,p->result,buff);
        }  
    }
}

static int do_verbose(lua_State* L)
{
    verbose = lua_toboolean(L,1);
    return 0;
}

// not implemented yet!
static int do_foreground(lua_State* L)
{
    return 0;
}

static int new_spawner(lua_State* L)
{
	Spawner* spp = (Spawner*)lua_newuserdata(L,sizeof(Spawner));
	memset(spp,0,sizeof(Spawner));
	spp->command_line = luaL_checkstring(L,1);
    spp->L = L;
    luaL_getmetatable(L,"SPAWNER");
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
	new_command = (char*)malloc(strlen(spp->command_line)+20);
	sprintf(new_command,"/bin/sh -c %s",spp->command_line);
	spp->command_line = new_command;
	return 0;
}

static int spawner_write(lua_State* L)
{
	Spawner* spp = (Spawner*)lua_touserdata(L,1);	
	const char* buff = luaL_checkstring(L,2);
    int res = fputs(buff,spp->child);
	lua_pushboolean(L,res > 0);
	return 1;
}

static int spawner_read(lua_State* L)
{
	Spawner* spp = (Spawner*)lua_touserdata(L,1);
    char* res = fgets(line,sizeof(line),spp->rdr);
    if (! res) {
        lua_pushnil(L);
    } else {
        lua_pushstring(L,res);
    }
	return 1;
}

void newfile_from_stream (lua_State *L, FILE *f);

static int spawner_run(lua_State* L)
{
	Spawner* spp = (Spawner*)lua_touserdata(L,1);
	if (! start_process(spp)) {
		lua_pushboolean(L,0);
		return 1;
	}
	if (spp->output != NULL) {
        spp->gdk_handle = gdk_input_add(spp->child_fd, GDK_INPUT_READ,
		                            (GdkInputFunction) read_callback, spp);

	}
	lua_pushboolean(L,1);
	return 1;
}

static int do_popen(lua_State* L)
{
    const char* cmd = lua_tostring(L,1);
    int inf,outf;
    int res = popen2(cmd,&inf,&outf);
    close(inf); 
    if (res == -1) {
        lua_pushboolean(L,0);
    } else {
        newfile_from_stream(L,fdopen(outf,"r"));
    }
	return 1;
}

static int do_popen2(lua_State* L)
{
    const char* cmd = lua_tostring(L,1);
    int inf,outf;
    int res = popen2(cmd,&inf,&outf);
    if (res == -1) {
        lua_pushboolean(L,0);
        return 1;
    } else {
        newfile_from_stream(L,fdopen(inf,"w"));
        newfile_from_stream(L,fdopen(outf,"r"));
        return 2;
    }
}

static int spawner_kill(lua_State* L)
{
	Spawner* spp = (Spawner*)lua_touserdata(L,1);
    kill(spp->pid,9);
	return 0;
}

/////// stuff from liolib

#define PIPE_FILEHANDLE "PIPE_FILE*"

// based on liolib.c
void newfile_from_stream (lua_State *L, FILE *f)
{
  FILE **pf = (FILE **)lua_newuserdata(L, sizeof(FILE *));
  *pf = NULL;
  luaL_getmetatable(L, PIPE_FILEHANDLE);
  lua_setmetatable(L, -2);
  *pf = f;
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
    {"verbose",do_verbose},
	{"new",new_spawner},
	{"popen",do_popen},
	{"popen2",do_popen2},
    {"foreground",do_foreground},
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

int luaopen_spawner(lua_State *L)
{
	createmeta(L);
	luaL_openlib (L, "spawner", spawner, 0);
	luaL_newmetatable(L, "SPAWNER");  // create metatable for spawner objects
	lua_pushvalue(L, -1);  // push metatable
	lua_setfield(L, -2, "__index");  // metatable.__index = metatable
	luaL_register(L, NULL, spawner_methods); 	
	return 1;	
}
