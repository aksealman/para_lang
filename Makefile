all: parser.o lexer.o 
	g++ -o trial lexer.o parser.o -lfl -w 

parser.o: parser.cpp
	g++ -c -o parser.o parser.cpp -fpermissive -w -lfl

parser.cpp:
	bison++ -d -hparser.h -oparser.cpp lang_parse.y 

lexer.o: scanner.cpp
	g++ -c -o lexer.o scanner.cpp -fpermissive -w -lfl


scanner.cpp:
	flex++ -oscanner.cpp lang_lex.l 

clean:
	rm -f *.o
	rm -f *.cpp
	rm -f *.h
	rm -f trial
