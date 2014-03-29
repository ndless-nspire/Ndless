CFLAGS := -std=c++11 -nostdlib -O3 -fpic -fno-exceptions -mlong-calls -Wall -Werror -I ../../include/

AR_FILE := ../libfornewlib.a
O_FILES := stdlib.o

all: $(AR_FILE)

$(AR_FILE): $(O_FILES)
	arm-none-eabi-ar rcs $@ $^
	
%.o: %.cpp
	arm-none-eabi-g++ $(CFLAGS) -c $^ -o $@
	
clean:
	rm -f $(AR_FILE) $(O_FILES)