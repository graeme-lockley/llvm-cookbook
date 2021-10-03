all: test test.ll main.pdf

test: test.cpp

test.bc: test.cpp
	clang++ -c test.cpp -o test.bc -emit-llvm
	opt -O1 test.bc -o test.bc

test.ll: test.bc
	llvm-dis test.bc

main.pdf: test.bc
	opt --dot-cfg -o /dev/null test.bc
	for file in .*.dot ; do \
		echo $$file ; \
		TARGET_FILE=$${file:1} ; \
		dot -Tpdf $$file -o $${TARGET_FILE%.dot}.pdf ; \
	done

clean:
	rm -f .*.dot *.pdf test test.bc test.ll