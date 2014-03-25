CONFIGFLAGS=$(shell pkg-config --cflags gtk+-2.0)

all: unix-spawner-ex.so

unix-spawner-ex.so: unix-spawner-ex.c
	gcc -g $(CONFIGFLAGS) -shared -o unix-spawner-ex.so unix-spawner-ex.c -lutil
    

