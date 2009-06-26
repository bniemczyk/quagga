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

FORCE:
