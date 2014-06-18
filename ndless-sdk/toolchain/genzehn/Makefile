all: genzehn

genzehn: genzehn.cpp
	g++ -Wall -Wextra -std=c++11 -lboost_program_options -I elfio-2.2 $^ -o $@

clean:
	rm -f genzehn
