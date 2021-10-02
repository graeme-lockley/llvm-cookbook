test: test.cpp

test.ll: test.cpp
	clang++ -c test.cpp -o test.bc -emit-llvm
	llvm-dis test.bc