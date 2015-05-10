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

class EvaluateResult
{
public:
	EvaluateResult() : buffer(nullptr) {}
	EvaluateResult(char16_t *start) : buffer(start) {}
	EvaluateResult(EvaluateResult &&other)
	{
		buffer = other.buffer;
		other.buffer = nullptr;
	}
	EvaluateResult &operator=(EvaluateResult &&other)
	{
		buffer = other.buffer;
		other.buffer = nullptr;
		return *this;
	}
	EvaluateResult(EvaluateResult &other) = delete;
	EvaluateResult &operator=(EvaluateResult &other) = delete;
	~EvaluateResult() { syscall<e_free, void>(buffer); }
	const char16_t *c_str() { return buffer; }
private:
	char16_t *buffer;
};

// Evaluates the math expression in input and returns a pre-allocated buffer (or nullptr), that has to be freed with evaluate_free
EvaluateResult evaluate(void *state1, void *state2, const char16_t *input)
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

const char16_t *calchook_exec(void *state1, void *state2, const char16_t *cmd, calchook_callback callback)
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

	// Evaluate all arguments
	EvaluateResult args_evaluated[args.size()];
	for(unsigned int i = 0; i < args.size(); ++i)
	{
		args_evaluated[i] = evaluate(state1, state2, args[i].c_str());
		if(!args_evaluated[i].c_str())
			return nullptr;
	}

	// Yes, this cast is ugly.
	return callback(state1, state2, args.size(), reinterpret_cast<char16_t**>(args_evaluated));
}

struct CalchookReg {
public:
	CalchookReg(const char16_t *name, calchook_callback callback) : callback(callback)
	{
		this->length = utf16_strlen(reinterpret_cast<const uint16_t*>(name)) - 1;
		this->name = new char16_t[this->length + 1];
		memcpy(this->name, name, 2*this->length + 2);
	}
	CalchookReg(CalchookReg &&other)
	{
		name = other.name;
		other.name = nullptr;
	}
	CalchookReg(CalchookReg &other) = delete;
	CalchookReg &operator=(CalchookReg &other) = delete;
	~CalchookReg()
	{
		delete[] name;
	}
	bool operator== (const char16_t *other)
	{
		return memcmp(name, other, length) == 0;
	}

	calchook_callback callback;
	char16_t *name;
	size_t length;
};

static std::vector<CalchookReg> calchook_registry;

calchook_callback calchook_get(const char16_t *cmd)
{
	for(auto&& reg : calchook_registry)
		if(reg == cmd)
			return reg.callback;

	return nullptr;
}

HOOK_DEFINE(calchook)
{
	const char16_t *cmd = reinterpret_cast<char16_t*>(HOOK_SAVED_REGS(calchook)[2]);

	calchook_callback callback = calchook_get(cmd);
	if(callback)
	{
		// Partially uninstall the hook to avoid recursion (also, hooks aren't reentrant)
		// In this case we only change the hook target address to the original instructions back
		// to avoid expensive I-Cache flushes
		uintptr_t *hook_address = reinterpret_cast<uintptr_t*>(syscall_addrs[ut_os_version_index][e_calc_cmd] + 4);
		*hook_address = reinterpret_cast<uintptr_t>(__calchook_end_instrs);

		void *state1 = reinterpret_cast<void*>(HOOK_SAVED_REGS(calchook)[0]);
		void *state2 = reinterpret_cast<void*>(HOOK_SAVED_REGS(calchook)[1]);
		uint32_t result = reinterpret_cast<uint32_t>(calchook_exec(state1, state2, cmd, callback));
		if(result)
			HOOK_SAVED_REGS(calchook)[2] = result;			
		// else TODO: What now?

		// Install the hook again
		*hook_address = reinterpret_cast<uintptr_t>(calchook);
	}

	HOOK_RESTORE_RETURN(calchook);
}

bool calchook_register(const char16_t *name, calchook_callback callback)
{
	if(name[utf16_strlen(reinterpret_cast<const uint16_t*>(name)) - 1] != '(' // Doesn't end on '('
		|| calchook_get(name)) // Already registered
		return false;

	calchook_registry.emplace_back(name, callback);
	return true;
}

const char16_t *calchook_ndls_run(void *, void *, unsigned int argc, char16_t *argv[])
{
	if(argc == 0)
		return u"\"Missing Argument!\"";

	unsigned int i;
	char *argv_prgm[argc];
	for(i = 0; i < argc; ++i)
	{
		size_t len = utf16_strlen(reinterpret_cast<uint16_t*>(argv[i]));
		argv_prgm[i] = new char[2*len + 1];
		if(!argv_prgm[i])
		{
			// Free already allocated argv_prgm
			for(unsigned int j = 0; j < i; ++j)
				delete[] argv_prgm[j];

			return u"\"Out of memory!\"";
		}

		// Strip quotes from strings
		if((*argv[i] == '"' && *(argv[i]+len-1) == '"')
			|| (*argv[i] == '\'' && *(argv[i]+len-1) == '\''))
		{
			*(argv[i]+len-1) = 0;
			utf162ascii(argv_prgm[i], reinterpret_cast<uint16_t*>(argv[i] + 1), 2*len);
		}
		else
			utf162ascii(argv_prgm[i], reinterpret_cast<uint16_t*>(argv[i]), 2*len);
	}

	int ret = ld_exec_with_args(argv_prgm[0], argc - 1, argv_prgm + 1, nullptr);

	// Free argv_prgm
	for(unsigned int j = 0; j < i; ++j)
		delete[] argv_prgm[j];

	// The return value is never freed, so use a static buffer
	static char16_t ret16[16]; static char retascii[16];
	snprintf(retascii, 16, "%d", ret);
	ascii2utf16(ret16, retascii, 16);
	return ret16;
}

void calchook_install()
{
	uint32_t address = syscall_addrs[ut_os_version_index][e_calc_cmd];
	if(address == 0)
		return;

	calchook_register(u"ndls_run(", calchook_ndls_run);
	HOOK_INSTALL(address, calchook);
}
