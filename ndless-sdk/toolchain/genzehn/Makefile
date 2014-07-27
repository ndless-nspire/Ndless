all: genzehn

uninstall:
	rm $(PREFIX)/bin/genzehn

install: genzehn
	mkdir -p $(PREFIX)/bin
	cp genzehn $(PREFIX)/bin

genzehn: genzehn.cpp
	g++ -Wall -Wextra -std=c++11 -lboost_program_options-mt -I elfio-2.2 $^ -lboost_program_options-mt -o $@

clean:
	rm -f genzehn
