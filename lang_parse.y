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

*DONE*1. I need to write a function that checks/inserts things into the var_table. I have repeated code around and creating a function for this would make things loads easier. 
	1a. Need to convert all of my var_table inserts into function calls. (unsure about the return value I belive it can be void).
*DONE*2. I need to write var_set to accept var=opperation and have that work out accordingly. I belive that this will work with the temp_container that I write.
3. I need to write some sort of print functionallity so that I can check to see if my programs are correct. As of now correct means it compiles. I need somthing a little bit stronger then that.
4. After these I need to create some other opperations. Then discuss with Chappell about creating functions in my generated language to promote readabillity/make and as a cooler idea.
4. 
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
| var_name EQUAL opperation
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



var_declare: varible var_name COLON LP type RP
			
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
opperation:
	var_name PLUS number	
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
				output_stream << "result_container = _mm_add_ps(" << string ($1) << ",temp_container);\n";
				$$ = strdup((output_stream.str()).c_str());

			}
	|
	var_name PLUS var_name
			{
				//in this case we allready have our two varibles so we just need our result continer
				//at this point both var_names should allready be defined in the code
				stringstream output_stream;
				vector <double> var_value;
				//ONCE AGAIN DO NOT KNOW RESULT FILL WITH 0's
				vector_fill(var_value,0,0,0,0);
				if(!var_table_check_set("result_container", var_value))
					output_stream << "__m128 ";
				output_stream << "result_container = _mm_add_ps(" << (string) $1 << "," << (string) $3 << ");\n";
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
