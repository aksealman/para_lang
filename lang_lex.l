//SEE LICENCE.TXT FOR COPYRIGHT

//Lex file which creates tokens for the Karrot programming language
//Created by Zak Williams 2014
%option c++
%option noyywrap

%{
#include <sstream>
#include <fstream>
#include <cstdlib>
#include <stdio.h>
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

"loop"				{return Parser::LOOP;}

"if"				{return Parser::IF;}

"else"				{return Parser::ELSE;}

"rand" 				{return Parser::RAND;}

"<" 				{return Parser::LT;}

">"				{return Parser::GT;}

"=="				{return Parser::DEQUAL;}

"{"				{return Parser::LB;}

"}"				{return Parser::RB;}

"("				{return Parser::LP;}

")"				{return Parser::RP;}

"+" 				{return Parser::PLUS;}

"-" 				{return Parser::MINUS;}

"\*"				{return Parser::MUL;}

"/"				{return Parser::DIV;}

"="				{return Parser::EQUAL;}

":"				{return Parser::COLON;}

","				{return Parser::COMMA;}

[a-zA-Z][0-9a-zA-Z]*		{return Parser::VAR_NAME;}

"#".*"\n"			; 
			
[[ \t\f\n]			;

.				{return Parser::UNKNOWN;}

%%


int main()
{
	cout << "No arguements taken debug mode." << endl;
	cout << endl;
	Parser parser;
	cout << parser.yyparse() << endl;	
	return 0;	
}
