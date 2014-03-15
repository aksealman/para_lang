#include <xmmintrin.h>
#include <iostream>
using namespace std;
float print_float[16];
int main()
{
	__m128 result_container;
	__m128 mask;
	
	__m128 x;
	__m128 y;
	x = _mm_setr_ps(1,2,3,4);
	y = _mm_setr_ps(1,2,3,4);
	for(int ii=0; ii < 20; ++ii)
	{
	result_container = _mm_add_ps(x,y);
	x = result_container;
	_mm_store_ps(print_float,y);
	for(int ii = 0; ii < 4; ++ii)
	{
		cout << print_float[ii] << " "; 
	}
	cout << endl;_mm_store_ps(print_float,y);
	for(int ii = 0; ii < 4; ++ii)
	{
		cout << print_float[ii] << " "; 
	}
	cout << endl;}
	
	_mm_store_ps(print_float,x);
	for(int ii = 0; ii < 4; ++ii)
	{
		cout << print_float[ii] << " "; 
	}
	cout << endl;
	_mm_store_ps(print_float,y);
	for(int ii = 0; ii < 4; ++ii)
	{
		cout << print_float[ii] << " "; 
	}
	cout << endl;
}
