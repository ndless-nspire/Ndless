all: libnavnet.a

libnavnet.a: libnavnet.def
	dlltool -d libnavnet.def -l libnavnet.a

libnavnet.def: ../include/navnet.h
	echo "LIBRARY navnet.dll" > $@
	echo "EXPORTS" >> $@
	sed -n 's/.*\(TI_NN_\w\+\).*/\1/p' $< >> $@
	
clean:
	rm -f libnavnet.a libnavnet.def
