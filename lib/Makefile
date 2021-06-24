LLVM_AS=llvm-as-10

all: ./lib.ll

./lib.ll: ./lib.c ./lib.h
	clang -emit-llvm -c -S ./lib.c -o ./lib.ll
	${LLVM_AS} ./lib.ll 

