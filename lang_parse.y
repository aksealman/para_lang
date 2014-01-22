%name Parser
%define LSP_NEEDED
%define MEMBERS \
          virtual ~Parser() {} \
	  Parser(string fname) {						          input_file.open(fname.c_str());						  lexer.switch_streams(input_file,NULL);}\
          private: \
                yyFlexLexer lexer;\
		ifstream input_file; 
%define LEX_BODY   {return lexer.yylex();}
%define ERROR_BODY {cerr << "error encountered at line: "<<lexer.lineno()<<"last word parsed:"<<lexer.YYText()<<"\n";}

/*
********************************************TODO***************************************
Zak Williams

As of now we have enough implemented in Flex++/Bison++ to start generating some c++ code these are the following three steps I would like to implement

1. Create someway to read in from a file instead of from the console (look at LEX_BODY/Main in the lexer tofind how to do this effectively). Also look at my previous pascall interprter in order to find out how.
2. Create a way to output the contents to a file instead of console.
3. Output a c++ framework to the file #include <xmmintrin.h> int main() { } somthing like this to create skellton of framework
*/

%header{
#include <iostream>
#include <fstream>
#include <stdio.h>
#include <stdlib.h>
#include <FlexLexer.h>
#include <string>
#include <string.h>
#include <sstream>
using namespace std;
%}

%token VAR_NAME NUMBER DECI_NUM TYPE VAR COLON LP RP EQUAL UNKNOWN

%%

program : expression   {};
expression : |
	expression statement
			 { 
				string temp = $2;
				cout << temp << endl;
			 };
statement :
	var_set           
			{				
				$$ = $1;

			}
	|
	var_declare 
			{			
				$$ = $1;
			};


var_set: var_name EQUAL LP number RP
			{
				stringstream output_stream;
				stringstream num_stream;
				num_stream << (string) $4 << ",";
				output_stream << "__mm128 " << string ($1) << " = _mm_setr_ps(" << num_stream.str() << num_stream.str() << num_stream.str() << (string) $4 << ");";
				$$ = strdup((output_stream.str()).c_str());	

			};
var_declare: varible var_name COLON LP type RP
			{
					stringstream ss;
					ss << "__mm128 " << (string) $2 << ";";
					$$ = strdup((ss.str()).c_str());
			};

number: NUMBER 		{
					string temp = lexer.YYText();
					$$ = strdup(temp.c_str());
			}
			|
	DECI_NUM	{
					string temp = lexer.YYText();
					$$ = strdup(temp.c_str());

			};
varible: VAR		{
					//need to cast input to a char pointer so that we can push it up
					string temp = lexer.YYText();
					$$ = strdup(temp.c_str());
			};

type : TYPE		{
				string temp = lexer.YYText();
				$$ = strdup(temp.c_str());
			};
var_name : VAR_NAME	{
				string temp = lexer.YYText();
				$$ = strdup(temp.c_str());
			};

%%
