CFLAGS=-g -O6
CC=gcc ${CFLAGS}
LD=gcc ${CFLAGS}

all: gctest

gctest: gctest.o gc.o
	$(LD) -o $@ $^

clean: FORCE
	rm -f *.o *.exe

FORCE:
