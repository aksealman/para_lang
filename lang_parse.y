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

one line if statemnts have been implemented. 

I have an idea for multi line if statements.

What we do right now for single line if statements is push two elements onto the stack we pop both of them off and see if they are equal. If they are then we are changing the same varible. Else we are not chaning the same varible and can do different operations.

So what we can attempt to do for multi line if statements is create an if and else clause. Inside both of these clauses we push all of the varibles into a map or somthing. We have two maps. If a varible is in one map but not the other then we execute our first case. If they are both the same then we execute our second case. This has some potential to lead into problems with differnet sized if statements but we will cross that bridge when we come to it.

This is my next train of thought. I will try doing this tommrow with another branch on git, and see how it plays out. I do not belive that I will have it implemented in time for dr chappell.

*/

%header{
#include <iostream>
#include <fstream>
#include <queue>
#include <stack>
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
extern unordered_map <string, bool> table_1;
extern unordered_map <string, bool> table_2;
extern queue <string> par_table;
extern stack <string> var_name_table;
extern bool var_table_check_set(string var_name, const vector<double>& var_values);
extern bool var_table_check(string var_name);
extern void par_table_push(string x);
extern void par_table_pop();
extern void vector_fill(vector <double>& var_values, double first, double second, double third, double forth);
%}



%token VAR_NAME ELSE COMMA NUMBER DECI_NUM TYPE VAR COLON LP RP IF EQUAL UNKNOWN PRINT SUM LOOP LB RB LT GT DEQUAL
%left PLUS MINUS MUL DIV



%%

program : expression   {};
expression : |
	expression statement
			 { 
				string temp = string ($2);
				cout << temp << endl;
				$$ = strdup(temp.c_str());
			 }
	
statement :
	if_statement
			{
				$$ = $1;
			}
	|
	loop_statement
			{
				$$ = $1;
			}
	|
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
				//WE NEED THE IF TABLE HERE TO GET JUST THE PLAIN EXPRESSION IF THIS IS CALLED FROM AN IF STATEMENT. IT IS A STACK SO ONLY THE RECENT VALUES MATTER. WE MAY NEED TO CHANGE THIS CODE SO TO CALL A SPECIFC GRAMMAR, HOWEVER AS OF RIGHT NOW I WOULD JUST LIKE TO GET THIS TO WORK.	
				par_table_pop();
			        $$ = strdup((output_stream.str()).c_str());				
			
			};

if_var_set:
	var_name EQUAL add_sub_exr
		{
		
				//as of now opperation contains temp container and result container.
				stringstream output_stream;
				output_stream << par_table.front();
				//ONCE AGAIN DO NOT KNOW WHAT TO FILL VEC_VALUE WITH SO JUST FILLING WITH 0's
				var_name_table.push(string ($1));
				par_table_pop();
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
				stringstream trial_stream;
				//$1 is not a varible then it is an operation, which should be on its own line
				if(!var_table_check(string ($1)) && !var_table_check(string ($3)))
				{
					output_stream << "result_container = " << string ($2) << "(" << par_table.front() << ",";
					trial_stream << string ($2) << "(" << par_table.front() << ",";
					par_table_pop();
					trial_stream << par_table.front() << ")";
					output_stream << par_table.front() << ");\n";
					par_table_pop();
				}
				else if(!var_table_check(string ($1)))
				{	
					output_stream << "result_container = " << string ($2) << "(" << par_table.front() << "," << string ($3) << ");\n";
					trial_stream << string ($2) << "(" << par_table.front() << "," << string ($3) << ")";
					par_table_pop();
				}
				else if(!var_table_check(string ($3)))
				{
					output_stream << "result_container = " << string ($2) << "(" << par_table.front() << "," << string ($1) << ");\n";
					trial_stream << string ($2) << "(" << par_table.front() << "," << string ($1) << ")";
					par_table_pop();
				}
				else
				{
					output_stream << "result_container = " << string ($2) << "(" << string ($1) << "," << string ($3) << ");\n";	
					trial_stream << string ($2) << "(" << string ($1) << "," << string ($3) << ")";
				}
				par_table_push(trial_stream.str());
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
		stringstream trial_stream;
		//If this condition is filled that means $1 is code
		//Need to check term as well, also means we need to check both
		if(!var_table_check(string($1)) && !var_table_check(string($3)))
		{
			output_stream << "result_container = " << string ($2) << "(" << par_table.front() << ",";
			trial_stream << string ($2) << "(" << par_table.front() << ",";
			par_table_pop();
			trial_stream << par_table.front() << ")";
			output_stream << par_table.front() << ");\n";
			par_table_pop();	
		}
		else if(!var_table_check(string ($1)))
		{	
			//output_stream << string ($1);
			output_stream << "result_container = " << string ($2) << "(" << par_table.front() << "," << string ($3) << ");\n";
			trial_stream << string ($2) << "(" << par_table.front() << "," << string ($3) << ")";	
			par_table_pop();
		}
		else if(!var_table_check(string ($3)))
		{
			output_stream << "result_container = " << string ($2) << "(" << par_table.front() << "," << string ($1) << ");\n";
			trial_stream << string ($2) << "(" << par_table.front() << "," << string ($1) << ")";	
			par_table_pop();
		}	
		else
		{
			output_stream << "result_container = " << string ($2) << "(" << string ($1) << "," << string ($3) << ");\n";
			trial_stream << string ($2) << "(" << string ($1) << "," << string ($3) << ")";
		}
		par_table_push(trial_stream.str());
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

loop_statement:
	LOOP LB conditional_expression RB
		{
			stringstream output_stream;
			output_stream << "for(int ii=0; ii < 1000; ++ii)\n{\n" << string ($3) << "}\n";	
			$$ = strdup((output_stream.str()).c_str());
		};
if_statement:
	IF conditional LB then_expression RB ELSE LB else_expression RB
	{
		/*Huge set of steps we need to execute here
		STEP 1. Create a mask of type conditional since we have mask included by default we do not need to reinit mask (_m128) **DONE**
		STEP 2. Mask the two results in the conditial operations. (via then and else)
		STEP 3. Store the result in some kind of contianer.
		As of right now just return the first conditional expression that works
		*/
		stringstream output_stream;
		output_stream << string ($2);
		vector <double> vec_value;
		vector_fill(vec_value, 0,0,0,0);
		//if not found add __m128 to the type
		if(!var_table_check_set("then", vec_value))
		{
			output_stream << "__m128 ";
		}
		output_stream << "then = " << string ($4) << ";\n";
		if(!var_table_check_set("else_m", vec_value))
		{
			output_stream << "__m128 ";
		}	
		output_stream << "else_m = " << string ($8) << ";\n";
		string second = var_name_table.top();
		var_name_table.pop();
		string first = var_name_table.top();
		var_name_table.pop();
		if(first == second)
		//Now to store the results. stores both in same varible. If we have seperate varibles we just need to use the and on one and the andnot on another
			output_stream << first << " = _mm_or_ps( _mm_and_ps(mask,then), _mm_andnot_ps(mask,else_m));\n";
		else
		{
			output_stream << first << " = _mm_or_ps(_mm_and_ps(mask,then),_mm_andnot_ps(mask," << first << "));\n";
			output_stream << second << " = _mm_or_ps(_mm_andnot_ps(mask,else_m),_mm_and_ps(mask," << second << "));\n";
		}
		//as of right now we do not have the var name to store. We need to somehow grab that.
    		$$ = strdup((output_stream.str()).c_str());	
	};
conditional:
      LP var_name con_op var_name RP
		{
			stringstream output_stream;
//			output_stream << string ($1) << string ($2) << string ($3) << "\n";
			//Create our mask assignment
			output_stream << "mask = "<< string ($3) << "(" << string ($2) << "," << string ($4) << ");\n";
			$$ = strdup((output_stream.str()).c_str());
		};
then_expression:	
	then_expression if_var_set_then
		{
			cout << var_name_table.size() << endl;
			/*Time to construct a string*/
			cout << string ($1) << endl;
			cout << endl;
			cout << string ($2) << endl;
			cout << endl;			
			cout << "end here" << endl;

			stringstream output_stream;
			output_stream << string ($2);
			$$ = strdup((output_stream.str()).c_str());

		}
	|
	if_var_set_then{};

else_expression:	
	else_expression if_var_set_else
		{
			cout << var_name_table.size() << endl;
			/*Time to construct a string*/
			cout << string ($1) << endl;
			cout << endl;
			cout << string ($2) << endl;
			cout << endl;			
			cout << "end here" << endl;

			stringstream output_stream;
			output_stream << string ($2);
			$$ = strdup((output_stream.str()).c_str());

		}
	|
	if_var_set_else{};


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

con_op:
	LT
		{
			string temp = "_mm_cmplt_ps";
			$$ = strdup(temp.c_str());
		}
	|
	GT
		{
			string temp = "_mm_cmpgt_ps";
			$$ = strdup(temp.c_str());
		}
	|
	DEQUAL
		{
			string temp = "_mm_cmpeq_ps";
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
queue <string> par_table;
stack <string> var_name_table;
/*
This function will check to see if the value var_name exsits in our global var_table as well as set the value of var_table to our vector we passed in
*/
bool var_table_check_set(string var_name, const vector <double> &var_values)
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

void par_table_push(string x)
{
//	cout << "pushing" << endl;
//	cout << x << endl;
//	cout << endl;
	par_table.push(x);
}
void par_table_pop()
{
//	cout << "popping" << endl;
//	cout << par_table.front() << endl;
//	cout << endl;
	par_table.pop();
}
void vector_fill(vector <double> & var_values, double first, double second, double third, double forth)
{
	var_values = {first,second,third,forth};
}
