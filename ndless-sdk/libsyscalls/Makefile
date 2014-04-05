CFLAGS := -std=c++11 -nostdlib -O3 -fpic -fno-exceptions -fno-rtti -mlong-calls -Wall -Werror -I ../include/

AR_FILE := ../lib/libsyscalls.a
O_FILES := stubs.o stdlib.o osvar.o
H_FILE := ../include/syscall-decls.h

all: $(AR_FILE)

$(AR_FILE): $(O_FILES)
	arm-none-eabi-ar rcs $@ $^
	
%.o: %.cpp
	arm-none-eabi-g++ $(CFLAGS) -c $^ -o $@
	
stubs.cpp: ../include/syscall-list.h mkStubs.php
	php mkStubs.php > $(H_FILE)
	
clean:
	rm -f $(AR_FILE) $(O_FILES) $(H_FILE) stubs.cpp
