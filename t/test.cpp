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

int throw_exception(int a, int b) {
	if (a > b) 
		throw Ex1(a + b);

	if (a == b) 
		throw Ex2(a * b);

	cout << "throw_exception: no exception to throw\n";

	return b - a;
}

int fred = 1;

int test_try_catch(int a, int b) {
	int result = 0;

	try {
		fred = 2;
		result = throw_exception(a, b);
		fred = 3;
	}
	catch(Ex1 e) {
		fred = 4;
		result = e.v;
	}

	fred = 5;
	return result;
}


int main(int argc, char *argv[]) {
	cout << test_try_catch(1, 2) << "\n";
	cout << test_try_catch(3, 1) << "\n";
	cout << test_try_catch(3, 3) << "\n";

	return 0;
}
