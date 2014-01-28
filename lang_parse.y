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
#include <vector>
#include <sstream>
#include <unordered_map>
using namespace std;
extern unordered_map <string, vector <double>> var_table;
%}



%token VAR_NAME COMMA NUMBER DECI_NUM TYPE VAR COLON LP RP EQUAL UNKNOWN PLUS MINUS




%%

program : expression   {};
expression : |
	expression statement
			 { 
				string temp = $2;	
				cout << temp << endl;
			 }
	
statement :
	var_set           
			{				
				$$ = $1;

			}
	|
	var_declare 
			{			
				$$ = $1;
			}
	|
	opperation
			{
				$$ = $1;
			};

opperation:
	var_name PLUS number	
			{
				//Step 1 create an __mm128 object containing four numbers 
				stringstream output_stream;
				stringstream num_stream;
				num_stream << string ($3) << ",";
				output_stream << "__m128 temp_container = _mm_setr_ps(";
				for(int ii = 0; ii < 3; ++ii)
						output_stream << num_stream.str();
				output_stream << string ($3) << ");\n";
				//Step 2 Create a result container (should be created before this proof of concept) for the addition to be carried in
				output_stream << "__m128 result_container = _mm_add_ps(" << string ($1) << ",temp_container);\n";
				$$ = strdup((output_stream.str()).c_str());

			};

var_set: var_name EQUAL LP number RP
			{
				stringstream output_stream;
				stringstream num_stream;
				num_stream << string ($4) << ",";
				//if not declared, declare it then send to 
				if(var_table.find((string) $1) == var_table.end())
				{
					cout << "inside if statement" << endl;
					output_stream << "__m128 " << string ($1) << " = _mm_setr_ps(";
					for(int ii = 0; ii < 3; ++ii)
						output_stream << num_stream.str();
					output_stream << string ($4) << ");";
					//turn this code into a function
					for(int ii =0; ii < 4; ++ii)
					{
						var_table[(string) $1].push_back((double) $4);
					}
				}
				//if its not declared just set equal
				else
				{
					output_stream << string ($1) << " = _mm_setr_ps(";
					for(int ii = 0; ii < 3; ++ii)
						output_stream << num_stream.str();
					output_stream << string ($4) << ");";
				}	
				$$ = strdup((output_stream.str()).c_str());	

			}
| var_name EQUAL LP number COMMA number COMMA number COMMA number RP
			{
				stringstream output_stream;
				stringstream num_stream;
				num_stream << string ($4) << "," << string ($6) << "," << string ($8) << "," << string ($10); 
				//check to see if var name is currently in our var table	
				if(var_table.find((string) $1) == var_table.end())
				{
					output_stream << "__m128 " << string ($1) << " = _mm_setr_ps(" << num_stream.str() << ");";
					var_table[(string) $1].push_back((double) $4);
					var_table[(string) $1].push_back((double) $6);
					var_table[(string) $1].push_back((double) $8);
					var_table[(string) $1].push_back((double) $10);
				}
				else
				{
					output_stream << string ($1) << " = _mm_setr_ps(" << num_stream.str() << ");";
				}
				
				$$ = strdup((output_stream.str()).c_str());

			};

var_declare: varible var_name COLON LP type RP
			
			{
				//if our varible is not found insert it into the hash and create it.
				if(var_table.find((string) $2) == var_table.end())
				{
					//initilize everything to zero unless otherwise needed
					for(int ii = 0; ii < 4; ++ ii)
						var_table[(string) $2].push_back(0);
					stringstream ss;
					ss << "__m128 " << (string) $2 << ";";
					$$ = strdup((ss.str()).c_str());
				}
				//if we reach here we have a syntatic error and must abort I am unsure how to do this yet.
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

unordered_map <string, vector <double>> var_table;

