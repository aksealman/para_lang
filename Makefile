all: parser.o lexer.o 
	@g++ -o /usr/bin/karrot_exe lexer.o parser.o -lfl -w -std=c++0x
	@cp program_pipe.py /usr/bin/karrot_compile
	@chmod 777 /usr/bin/karrot_compile
	@cp karrot_run.sh /usr/bin/karrot
	@chmod 777 /usr/bin/karrot
parser.o: parser.cpp
	@g++ -c -o parser.o parser.cpp -fpermissive -w -lfl -std=c++0x

parser.cpp:
	@bison++ -d -v -hparser.h -oparser.cpp lang_parse.y 

lexer.o: scanner.cpp
	@g++ -c -o lexer.o scanner.cpp -fpermissive -lfl -w -std=c++0x


scanner.cpp:
	@flex++ -oscanner.cpp lang_lex.l 

clean:
	@rm -f *.o
	@rm -f *.cpp
	@rm -f *.h
	@rm -f /usr/bin/karrot_compile
	@rm -f /usr/bin/karrot
