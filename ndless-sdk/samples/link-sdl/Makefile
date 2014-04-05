SOURCES = link.c
TARGET = Link.tns
OBJECTS = $(SOURCES:.c=.o)

CC = nspire-gcc
LD = nspire-ld
OBJCOPY = arm-none-eabi-objcopy
CFLAGS = -Wall -Wextra -Ofast
LDFLAGS =
LIBS = -lSDL

all: $(TARGET)

$(TARGET): $(OBJECTS)
	$(LD) $(LDFLAGS) $^ -o $@

.c.o:
	$(CC) $(CFLAGS) -c $< -o $@

clean:
	rm -f $(OBJECTS) $(TARGET:.tns=.elf) $(TARGET)
