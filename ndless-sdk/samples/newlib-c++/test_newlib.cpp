#include <iostream>
#include <fstream>

using namespace std;

int main(int, char **)
{
	cout << "Hello World!" << endl;
	
	ifstream themes("/documents/themes.csv");
	string line;
	if(!themes.is_open())
	{
		cerr << "Couldn't open themes.csv!" << endl;
		return 1;
	}

	cout << "Your themes.csv:" << endl;
	while(getline(themes, line))
		cout << line << endl;

	themes.close();

	return 0;
}
