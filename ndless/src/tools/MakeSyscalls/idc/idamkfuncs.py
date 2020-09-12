import idc

# Try to mark all unknown bytes as subroutines

def define_functions():
	ea = 0x10000000
	unknown = idc.FindUnexplored(ea, idc.SEARCH_DOWN)
	while unknown != idc.BADADDR and unknown < 0x11000000:
		insn = idc.Dword(unknown)
		if insn & 0xF0000000 == 0xE0000000 and unknown & 3 == 0 and idc.MakeCode(unknown) == 4:
			print "Trying %x" % unknown
			if idc.MakeFunction(unknown):
				print "Success"
			else:
				unknown += 4
			unknown = idc.FindUnexplored(unknown, idc.SEARCH_DOWN)
		else:
			unknown += 4
			unknown = idc.FindUnexplored(unknown, idc.SEARCH_DOWN)

define_functions()
