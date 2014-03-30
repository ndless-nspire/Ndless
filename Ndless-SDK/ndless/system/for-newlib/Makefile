CFLAGS := -std=c++11 -nostdlib -O3 -fpic -fno-exceptions -mlong-calls -Wall -Werror -I ../../include/

O_FILES := stdlib.o

all: $(O_FILES)

%.o: %.cpp
	arm-none-eabi-g++ $(CFLAGS) -c $^ -o $@

clean:
	rm -f $(O_FILES)

