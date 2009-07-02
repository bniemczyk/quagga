all: build

configure: FORCE
	runhaskell Setup.hs configure

build: configure FORCE
	runhaskell Setup.hs build

install: FORCE
	runhaskell Setup.hs install

clean: FORCE
	runhaskell Setup.hs clean

shell: FORCE
	ghci -fglasgow-exts

sdist: FORCE
	runhaskell Setup.hs sdist

test: build FORCE
	dist/build/lc/lc test.lc |tee test.hs
	ghc --make test.hs -fglasgow-exts
	./test

FORCE:
