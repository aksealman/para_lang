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

CURRENT WORK IS GETTING ORDER OF OPERATIONS COMPLETED

CURRENTLY WORKING I HAVE NO IDEA WHY NEED TO DO SOME CLEANUP AND STUFF
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
extern bool var_table_check_set(string var_name, vector<double>& var_values);
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
	AddSubExr
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
| var_name EQUAL AddSubExr 
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
AddSubExr:

	
	AddSubExr sum_operator MulDivExr
			{
			 	cout << "entered the twlight zone" << endl;
				cout << endl;
			}
	|
	MulDivExr
			{
				
			}
	|
	AddSubExr sum_operator var_name
			{
				//The result of the most recent opperation is going to be stored in result container (I WILL need to change this for order of opperations just handling x+y+z)
				stringstream output_stream; 
				output_stream << string ($1) << "result_container = " << string ($2) << "(" << string ($3) << ",result_container);\n";
				$$ = strdup((output_stream.str()).c_str());

			}
	|
	var_name operator number	
			{
				//Step 1 create an __mm128 object containing four numbers 
				stringstream output_stream;
				stringstream num_stream;
				num_stream << string ($3) << ",";
				vector <double> vec_value;
				vector_fill(vec_value, (double) $3, (double) $3, (double) $3, (double) $3);
				if(!var_table_check_set("temp_container", vec_value))
					output_stream << "__m128 ";
				output_stream << "temp_container = _mm_setr_ps(";
				for(int ii = 0; ii < 3; ++ii)
						output_stream << num_stream.str();
				output_stream << string ($3) << ");\n";
				//Step 2 Create a result container (should be created before this proof of concept) for the addition to be carried in
				//CURRENTLY FILLING RESULT CONTAINER WITH 0's AS I DO NOT KNOW THE SIGNIFICANCE OF CALCULATING THE VALUE OF IT.
				vector_fill(vec_value,0,0,0,0);
				if(!var_table_check_set("result_container", vec_value))
				{
					output_stream << "__m128 ";
				}	
				output_stream << "result_container = " << string ($2) << "(" << string ($1) << ",temp_container);\n";
				$$ = strdup((output_stream.str()).c_str());

			}
	|
	var_name sum_operator MulDivExr
			{
				//in this case we allready have our two varibles so we just need our result continer
				//at this point both var_names should allready be defined in the code
				stringstream output_stream;
				vector <double> var_value;
				//ONCE AGAIN DO NOT KNOW RESULT FILL WITH 0's
				vector_fill(var_value,0,0,0,0);
				output_stream << string ($3);
				if(!var_table_check_set("result_container", var_value))
					output_stream << "__m128 ";
				output_stream << "result_container = " << string ($2) << "(" << string ($1) << "," << "result_container" << ");\n";
				$$ = strdup((output_stream.str()).c_str());
			}
	|
	SUM LP var_name RP
			{
				//Need to check and see if this is the most efficient way to compute a sum of an _m128 object
				stringstream output_stream;
				output_stream << "_mm_store_ps(print_float," << (string) $3 << ");\n";
				output_stream << "for(int ii = 0; ii < 4; ++ii)\n{\n_m128_result+=print_float[ii];\n}\ncout << _m128_result << endl;\n_m128_result=0;\n";
				$$ = strdup((output_stream.str()).c_str());
			};

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
operator: mul_operator {}
|
	  sum_operator {};

MulDivExr:
	MulDivExr mul_operator var_name
	{
		//Eventually turn var_name into factor? This is so parenthsis will work
		stringstream output_stream;
		output_stream << string ($1);
		output_stream << "result_container = " << string ($2) << "(result_container," << string ($3) << ");\n";
		$$ = strdup((output_stream.str()).c_str());
			
	}
	|
	var_name mul_operator var_name 
	{
				//in this case we allready have our two varibles so we just need our result continer
				//at this point both var_names should allready be defined in the code
				stringstream output_stream;
				vector <double> var_value;
				//ONCE AGAIN DO NOT KNOW RESULT FILL WITH 0's
				vector_fill(var_value,0,0,0,0);
				if(!var_table_check_set("result_container", var_value))
					output_stream << "__m128 ";
				output_stream << "result_container = " << string ($2) << "(" << string ($1) << "," << (string) $3 << ");\n";
				$$ = strdup((output_stream.str()).c_str());	
	}
	|
	var_name{};


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
	if(var_table.find(var_name) == var_table.end())
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

//filles a vector of with values first,second,thrid and forth. Could do this via initilizer list but this is cleaner.
//var_values should be an empty vector otherwise this program will not work
void vector_fill(vector <double> & var_values, double first,double second, double third, double forth)
{
	var_values = {first,second,third,forth};
}
