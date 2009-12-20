CFLAGS=-g -O0
CC=gcc ${CFLAGS}
LD=gcc ${CFLAGS}

all: test

test: test.o gc.o
	$(LD) -o $@ $^

clean: FORCE
	rm -f *.o *.exe

FORCE:
