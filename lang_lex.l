%option c++
%option noyywrap

%{
#include <sstream>
#include <fstream>
#include <cstdlib>
#include <iostream>
#include "parser.h"

using std::cout;
using std::endl;
using std::cin;
using std::cerr;
using std::ifstream;
using std::fstream;
using std::ofstream;
using std::stringstream;
%}

OPP [+|-|*|/]
DIGIT [0-9]
DIGIT1 [1-9]


%%
{DIGIT1}{DIGIT}*		{return Parser::NUMBER;}

{DIGIT}+\.?{DIGIT}+		{return Parser::DECI_NUM;}

"var"				{return Parser::VAR;}

"double" 			{return Parser::TYPE;}

"print" 			{return Parser::PRINT;}

"sum"				{return Parser::SUM;}

"("				{return Parser::LP;}

")"				{return Parser::RP;}

"+" 				{return Parser::PLUS;}

"-" 				{return Parser::MINUS;}

"="				{return Parser::EQUAL;}

":"				{return Parser::COLON;}

","				{return Parser::COMMA;}

[a-zA-Z][0-9a-zA-Z]*		{return Parser::VAR_NAME;}

[ \t\f\n]			;

.				{return Parser::UNKNOWN;}

%%


int main(int argc, char* argv[])
{
	ifstream compile_file;
	stringstream file_info;
	string file_name;
	if(argc < 2)
	{
		cout << "No arguements taken debug mode." << endl;
		cout << endl;
		Parser parser;
//		while(true)
//		{
			cout << parser.yyparse() << endl;
		
//		}
		return 0;	
	}
	else if(argc == 2)	
	{
		cout << "Loading file " << argv[1] << endl;
		file_name = argv[1];
	}
	Parser parser(file_name);
	cout << "attempting first parse" << endl;
	parser.yyparse();
	cout << "first parse" << endl;	
	cout << endl;
	return 0;
}
