#include <vector>

#include <syscall-list.h>
#include <syscall-addrs.h>
#include <syscall.h>
#include <hook.h>

#include "calchook.h"
#include "ndless.h"

// There has to be a better way, but vector<char16_t> pulls in too much.
class UTF16String
{
public:
	UTF16String(const char16_t *start, size_t length)
	{
		buffer = new char16_t[length + 1];
		memcpy(buffer, start, length * sizeof(char16_t));
		buffer[length] = 0;
	}
	UTF16String(UTF16String &&other)
	{
		buffer = other.buffer;
		other.buffer = nullptr;
	}
	UTF16String &operator=(UTF16String &&other)
	{
		buffer = other.buffer;
		other.buffer = nullptr;
		return *this;
	}
	UTF16String(UTF16String &other) = delete;
	UTF16String &operator=(UTF16String &other) = delete;
	~UTF16String()
	{
		delete[] buffer;
	}
	const char16_t *c_str() { return buffer; }
private:
	char16_t *buffer;
};

// Evaluates the math expression in input and returns a pre-allocated buffer (or nullptr), that has to be freed with evaluate_free
char16_t *evaluate(void *state1, void *state2, const char16_t *input)
{
	void *math_expr = nullptr;
	int str_offset = 0;

	int error_code = TI_MS_evaluateExpr_ACBER(state1, state2, reinterpret_cast<const uint16_t*>(input), &math_expr, &str_offset);
	if(error_code)
		return nullptr;

	uint16_t *ret;
	TI_MS_MathExprToStr(math_expr, state2, &ret);
	syscall<e_free, void>(math_expr); // Should be TI_MS_DeleteMathExpr
	return reinterpret_cast<char16_t*>(ret);
}

void evaluate_free(char16_t *ptr)
{	
	syscall<e_free, void>(ptr);
}

// Returns pointer to the first character after this argument.
// Example: expr1,expr2
// Input:   ^
// Output:       ^
const char16_t *find_arg_end(const char16_t *start)
{
	int depth = 0;
	bool quoted = false;
	while(*start)
	{
		switch(*start)
		{
		case ',':
			if(depth == 0 && !quoted)
				return start;
			break;
		case '(':
			++depth;
			break;
		case ')':
			// We hit the closing ')'
			if(depth == 0)
				return start;
			--depth;
			break;
		case '"':
			quoted = !quoted;
			break;
		}
		++start;
	}
	return start;
}

const char16_t *calchook_exec(void *state1, void *state2, const char16_t *cmd)
{
	std::vector<UTF16String> args;

	// Skip to  V
	// ndls_run(expr1,expr2)
	const char16_t *start = cmd + 9;
	while(true)
	{
		const char16_t *next = find_arg_end(start);
		if(next == start)
			break;

		args.emplace_back(start, next - start);
		start = next + 1;
	}

	if(args.size() == 0)
		return u"\"Missing Argument!\"";

	char *argv[args.size()];
	for(unsigned int i = 0; i < args.size(); ++i)
	{
		char16_t *res = evaluate(state1, state2, args[i].c_str());
		if(!res)
			return nullptr;

		size_t len = utf16_strlen(reinterpret_cast<uint16_t*>(res));
		argv[i] = new char[2*len + 1];
		if(!argv[i])
		{
			evaluate_free(res);
			return u"\"Out of memory!\"";
		}

		// Strip quotes from strings
		if(*res == '"' && *(res+len-1) == '"')
		{
			*(res+len-1) = 0;
			utf162ascii(argv[i], reinterpret_cast<uint16_t*>(res + 1), 2*len);
		}
		else
			utf162ascii(argv[i], reinterpret_cast<uint16_t*>(res), 2*len);

		evaluate_free(res);
	}

	int ret = ld_exec_with_args(argv[0], args.size() - 1, argv + 1, nullptr);

	// The return value is never freed, so use a static buffer
	static char16_t ret16[16]; static char retascii[16];
	snprintf(retascii, 16, "%d", ret);
	ascii2utf16(ret16, retascii, 16);
	return ret16;
}

HOOK_DEFINE(calchook)
{
	//TODO: Don't uninstall the hook everytime, as it flushes the cache.
	//For now it's done to avoid recursion.
	uint32_t address = syscall_addrs[ut_os_version_index][e_calc_cmd];
	HOOK_UNINSTALL(address, calchook);

	void *state1 = reinterpret_cast<void*>(HOOK_SAVED_REGS(calchook)[0]);
	void *state2 = reinterpret_cast<void*>(HOOK_SAVED_REGS(calchook)[1]);
	const char16_t *cmd = reinterpret_cast<char16_t*>(HOOK_SAVED_REGS(calchook)[2]);

	const char16_t ndls_run[] = u"ndls_run(";
	if(!memcmp(cmd, ndls_run, sizeof(ndls_run) - sizeof(char16_t)))
	{
		uint32_t result = reinterpret_cast<uint32_t>(calchook_exec(state1, state2, cmd));
		if(result)
			HOOK_SAVED_REGS(calchook)[2] = result;			
		// else TODO: What now?
	}

	HOOK_INSTALL(address, calchook);
	HOOK_RESTORE_RETURN(calchook);
}

void calchook_install()
{
	uint32_t address = syscall_addrs[ut_os_version_index][e_calc_cmd];
	if(address == 0)
		return;

	HOOK_INSTALL(address, calchook);
}
