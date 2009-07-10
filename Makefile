CPP=cpp-4.4 -ISPJ/LC/lib

all: build

configure: 
	runhaskell Setup.hs configure

build: configure
	runhaskell Setup.hs build

install: FORCE
	runhaskell Setup.hs install

clean: FORCE
	runhaskell Setup.hs clean

shell: FORCE
	ghci -fglasgow-exts

sdist: FORCE
	runhaskell Setup.hs sdist

test: build
	$(CPP) test.lc | dist/build/lc/lc | tee test.hs
	ghc --make test.hs -fglasgow-exts
	./test

abs: build
	ghc --make SPJ/LC/Testlc.hs
	$(CPP) test.lc | SPJ/LC/Testlc

parser: SPJ/lc.cf
	bnfc -p 'SPJ.LC' SPJ/lc.cf
	happy -gca SPJ/LC/Parlc.y
	alex -g SPJ/LC/Lexlc.x
	(cd SPJ/LC/; latex Doclc.tex; dvips Doclc.dvi -o Doclc.ps)

pdf: FORCE
	dvipdf SPJ/LC/Doclc.dvi SPJ/LC/Doclc.pdf
	okular SPJ/LC/Doclc.pdf

FORCE:
