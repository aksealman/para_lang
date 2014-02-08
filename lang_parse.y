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

As of right now what we have is a programming language that currently keeps track of declared varibles, basic equalitly and such the following are the things I need to get done in order of prority.

Have order of opperations completed, I now need to handle parentheses
*/

%header{
#include <iostream>
#include <fstream>
#include <stdio.h>
#include <stdlib.h>
#ifndef YY_INTERACTIVE
#include <FlexLexer.h>
#endif
#include <string>
#include <string.h>
#include <vector>
#include <sstream>
#include <unordered_map>
using namespace std;
extern unordered_map <string, vector <double>> var_table;
extern bool var_table_check_set(string var_name, vector<double>& var_values);
extern bool var_table_check(string var_name);
extern void vector_fill(vector <double>& var_values, double first, double second, double third, double forth);
%}



%token VAR_NAME COMMA NUMBER DECI_NUM TYPE VAR COLON LP RP EQUAL UNKNOWN PRINT SUM
%left PLUS MINUS MUL DIV



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
	add_sub_exr
			{
				$$ = $1;
			}
	|
	print_statement
			{
				$$ = $1;
			};



var_set: var_name EQUAL LP number RP
			{
				stringstream output_stream;
				stringstream num_stream;
				num_stream << string ($4) << ",";
				//if not declared, declare it then send to 
				vector <double> vec_value;
				vector_fill(vec_value, (double) $4, (double) $4, (double) $4, (double) $4);
				//if not found add __m128 to the type
				if(!var_table_check_set((string) $1, vec_value))
				{
					output_stream << "__m128 ";
				}
				output_stream << (string) $1 << " = _mm_setr_ps(";
				for(int ii = 0; ii < 3; ++ ii)
					output_stream << num_stream.str();
				output_stream << (string) $4 << ");";
				$$ = strdup((output_stream.str()).c_str());	

			}
| var_name EQUAL LP number COMMA number COMMA number COMMA number RP
			{
				stringstream output_stream;
				stringstream num_stream;
				num_stream << "(" << string ($4) << "," << string ($6) << "," << string ($8) << "," << string ($10) << ");"; 
				vector <double> vec_value;
				vector_fill(vec_value, (double) $4, (double) $6, (double) $8, (double) $10);
				if(!var_table_check_set((string) $1, vec_value))
					output_stream << "__m128 ";
				output_stream << (string) $1 << " = _mm_setr_ps" << num_stream.str();
				$$ = strdup((output_stream.str()).c_str());

			}
| var_name EQUAL add_sub_exr 
			{
				//as of now opperation contains temp container and result container.
				stringstream output_stream;
				vector <double> var_value;
				output_stream << (string) $3;
				//ONCE AGAIN DO NOT KNOW WHAT TO FILL VEC_VALUE WITH SO JUST FILLING WITH 0's
				vector_fill(var_value,0,0,0,0);	
				if(!var_table_check_set((string) $1, var_value))
					output_stream << "__m128 ";
				output_stream << (string) $1 << " = result_container;\n";
			        $$ = strdup((output_stream.str()).c_str());				
			
			};



var_declare: variable var_name COLON LP type RP
			
			{
				vector <double> var_value;
				vector_fill(var_value,0,0,0,0);
				if(!var_table_check_set((string)$2, var_value))
				{
					stringstream ss;
					ss << "__m128 " << (string) $2 << ";";	
					$$ = strdup((ss.str()).c_str());
				}
				//if we reach here we have a syntatic error and must abort I am unsure how to do this yet.
				else
				{
				
					$$ = "";
				}
			};
add_sub_exr:
	mul_div_exr      {}
	|
	add_sub_exr sum_operator mul_div_exr
			{
			 	stringstream output_stream;
				vector <double> var_value;
				vector_fill(var_value,0,0,0,0);
				//$1 is not a varible then it is an operation, which should be on its own line
				if(!var_table_check(string ($1)))
				{
					output_stream << string ($1); 
					output_stream << "result_container = " << string ($2) << "(result_container," << string ($3) << ");\n";
				}
				else if(!var_table_check(string ($3)))
				{
					output_stream << string ($3); 
					output_stream << "result_container = " << string ($2) << "(result_container," << string ($1) << ");\n";
				}
				else
				{
					if(!var_table_check_set("result_container", var_value))
						output_stream << "__m128 ";
					output_stream << "result_container = " << string ($2) << "(" << string ($1) << "," << string ($3) << ");\n";					
				}
				$$ = strdup((output_stream.str()).c_str());

			};

mul_div_exr:
	term {}
	|
	mul_div_exr mul_operator term
	{
		//Eventually turn var_name into factor? This is so parenthsis will work
		stringstream output_stream;
		vector <double> var_value;
		vector_fill(var_value,0,0,0,0);
		//If this condition is filled that means $1 is code
		if(!var_table_check(string ($1)))
		{
			output_stream << string ($1); 
			output_stream << "result_container = " << string ($2) << "(result_container," << string ($3) << ");\n";
		}	
		else
		{
			if(!var_table_check_set("result_container", var_value))
				output_stream << "__m128 ";
			output_stream << "result_container = " << string ($2) << "(" << string ($1) << "," << string ($3) << ");\n";
		}
		$$ = strdup((output_stream.str()).c_str());
			
	};
term: 
	LP add_sub_exr RP
	{
		stringstream output_stream;
		output_stream << string ($2);
		$$ = strdup((output_stream.str()).c_str());
	}
	|
	var_name 
	{};


print_statement:
	PRINT var_name
			{
				stringstream output_stream;
				output_stream << "_mm_store_ps(print_float," << (string) $2 << ");\n";
				output_stream << "for(int ii = 0; ii < 4; ++ii)\n{\n\tcout << print_float[ii] << \" \"; \n}\ncout << endl;";	
				$$ = strdup((output_stream.str()).c_str());	

			}
	|
	PRINT number
			{
				stringstream output_stream;
				output_stream << "cout << " << (string) $2 << " << endl;";
				$$ = strdup((output_stream.str()).c_str());		
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
mul_operator:
 	MUL 	
		{
			string temp = "_mm_mul_ps";
			$$ = strdup(temp.c_str());
		}
|
	DIV
		{
			//WARNING THIS IS VERY SLOW
			string temp = "_mm_div_ps";
			$$ = strdup(temp.c_str());
		};


sum_operator:
	PLUS
		{
			string temp = "_mm_add_ps";
			$$ = strdup(temp.c_str());
		}
|
	MINUS 	
		{
			string temp = "_mm_sub_ps";
			$$ = strdup(temp.c_str());
		};

variable: VAR		{
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

/*
This function will check to see if the value var_name exsits in our global var_table as well as set the value of var_table to our vector we passed in
*/
bool var_table_check_set(string var_name, vector <double> &var_values)
{	
	if(!var_table_check(var_name))
	{
		for(int ii = 0; ii < 4; ++ii)
		{
			var_table[var_name].push_back(var_values[ii]);
		}	
		return false;
	}	
	else
	{
		for(int ii = 0; ii < 4; ++ii)
		{
			var_table[var_name][ii] = var_values[ii];
		}
		return true;
	}
}

bool var_table_check(string var_name)
{
	//return false if not found
	return !(var_table.find(var_name) == var_table.end());
}


void vector_fill(vector <double> & var_values, double first, double second, double third, double forth)
{
	var_values = {first,second,third,forth};
}
