all:
	happy -gca Parquagga.y
	alex -g Lexquagga.x
	latex Docquagga.tex
	dvips Docquagga.dvi -o Docquagga.ps
	ghc --make Testquagga.hs -o Testquagga
clean:
	 rm -f *.log *.aux *.hi *.o *.dvi Docquagga.ps *.o
distclean: clean
	 rm -f Docquagga.* Lexquagga.* Parquagga.* ParquaggaData.* Layoutquagga.* Skelquagga.* Printquagga.* Testquagga.* Absquagga.* Testquagga ErrM.* SharedString.* quagga.dtd XMLquagga.*
