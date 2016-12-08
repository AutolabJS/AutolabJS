#include <iostream>
#include "Test.hpp"

using namespace std;

int main()
{
    try {
	cout << test() << endl;
    }
    catch(...) {
	cout << 125 << endl;
    }
	return 0;
}
