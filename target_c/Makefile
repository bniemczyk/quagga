CC=gcc -g -O0
LD=gcc -g -O0

all: test

test: test.o gc.o
	$(LD) -o $@ $^

clean: FORCE
	rm -f *.o

FORCE:
