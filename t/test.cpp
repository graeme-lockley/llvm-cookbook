#include <iostream>

using namespace std;

class Ex1{
	public:
		int v;

	Ex1(int _v) {
		v = _v;
	}
};

class Ex2{
	public:
	int v;

	Ex2(int _v) {
		v = _v;
	}
};

void throw_exception(int a, int b) {
	if (a > b) 
		throw Ex1(a + b);

	if (a == b) 
		throw Ex2(a * b);
}

int test_try_catch(int a, int b) {
	try {
		throw_exception(a, b);
	}
	catch(Ex1 e) {
		return e.v;
	}

	return 0;
}


int main(int argc, char *argv[]) {
	cout << test_try_catch(1, 2) << "\n";
	cout << test_try_catch(3, 1) << "\n";
	cout << test_try_catch(3, 3) << "\n";

	return 0;
}
