#include <xmmintrin.h>
#include <iostream>
using namespace std;
float print_float[16];
int main()
{
	__m128 result_container;
	__m128 mask;
	
	__m128 x;
	x = _mm_setr_ps(5,5,5,5);
	__m128 y;
	y = _mm_setr_ps(1,2,3,4);
	__m128 a;
	a = _mm_setr_ps(1,1,1,1);
	__m128 z;
	result_container = _mm_mul_ps(_mm_add_ps(y,z),x);
	z = result_container;
	
	result_container = _mm_add_ps(_mm_add_ps(_mm_add_ps(z,z),_mm_mul_ps(x,y)),z);
	z = result_container;
	
	result_container = _mm_add_ps(_mm_add_ps(_mm_mul_ps(z,x),_mm_add_ps(_mm_add_ps(z,z),_mm_mul_ps(x,y))),x);
	z = result_container;
	
	result_container = _mm_add_ps(_mm_add_ps(_mm_mul_ps(_mm_mul_ps(z,x),x),y),x);
	z = result_container;
	
	result_container = _mm_add_ps(_mm_mul_ps(_mm_add_ps(z,z),_mm_add_ps(y,z)),_mm_add_ps(x,y));
	z = result_container;
	
	result_container = _mm_add_ps(_mm_mul_ps(_mm_mul_ps(_mm_add_ps(_mm_div_ps(_mm_add_ps(_mm_mul_ps(z,x),y),x),x),y),z),_mm_add_ps(_mm_mul_ps(_mm_sub_ps(_mm_add_ps(x,y),z),x),z));
	z = result_container;
	
}
