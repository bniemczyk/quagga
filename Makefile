CPP=cpp-4.4 -IQuagga/LC/lib

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

test: test.lc FORCE
	# $(CPP) test.lc | dist/build/lcc/lcc > test.lcb
	$(CPP) test.lc | dist/build/lch/lch | tee test.hs
	ghc --make test.hs -fglasgow-exts
	./test

abs: build
	ghc --make Quagga/LC/Testlc.hs
	$(CPP) test.lc | Quagga/LC/Testlc

parser: Quagga/lc.cf
	bnfc -p 'Quagga.LC' Quagga/lc.cf
	happy -gca Quagga/LC/Parlc.y
	alex -g Quagga/LC/Lexlc.x
	(cd Quagga/LC/; latex Doclc.tex; dvips Doclc.dvi -o Doclc.ps)

pdf: FORCE
	dvipdf Quagga/LC/Doclc.dvi Quagga/LC/Doclc.pdf
	okular Quagga/LC/Doclc.pdf 2> /dev/null

FORCE:
